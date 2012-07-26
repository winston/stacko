require 'aws-sdk'

module Stacko

  class Server
    class << self

      # Runs through the steps for creating a new EC2 instance
      #
      # Parameters
      #   * yaml: a hash read from a yaml file (possibly from config/stacko.yml) in the format:
      #       aws:
      #         access_key_id: "123"
      #         secret_access_key: "abc"
      #         ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"
      #       env:
      #         staging:
      #           image_id: "ami-1234"
      #           instance_type: "m1.small"
      #         production:
      #           image_id: "ami-1234"
      #           instance_type: "m1.large"
      #   * environment: the environment to spin up the EC2 instance (staging, production etc)
      #
      def create(yaml, environment)
        # FIXME: Check if environment is already running?

        if valid_config?(yaml, environment)
          stack = Stacko::Server.new(yaml["aws"])
          stack.create_key_pair
          stack.create_security_group
          stack.create_instance(environment, yaml["env"][environment])
          stack.save_to_yaml
        else
          puts "==> Stacko failed to create an EC2 instance. Please ensure that your config file is properly formatted."
        end
      end

      def valid_config?(yaml, environment)
        aws_config = yaml["aws"]
        ec2_config = yaml["env"][environment]

        if aws_config.nil? || %w(access_key_id, secret_access_key).all? { |k| aws_config[k].nil? } ||
           ec2_config.nil? || %w(image_id, instance_type).all? { |k| ec2_config[k].nil? }
          false
        else
          true
        end
      end

    end

    # Initializes EC2
    #
    # Parameters
    #   * config: a hash with the following keys:
    #       - access_key_id               AWS access key id.      E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
    #       - secret_access_key           AWS secret access key.  E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
    #       - ec2_endpoint [optional]     AWS region.             Defaults to "ec2.us-east-1.amazonaws.com".
    #
    def initialize(config)
      puts "==> Initializing EC2..."

      @aws_ec2 = AWS::EC2.new(config)
    end

    # Creates key pair in AWS
    #
    def create_key_pair
      puts "==> Creating key pair..."

      @key_pair = @aws_ec2.key_pairs.create(key_name)
      File.open(private_key_filename, "w", 0600) do |file|
        file.write(@key_pair.private_key)
      end

      puts "==> Successfully created key pair '#{key_name}'"
    rescue AWS::EC2::Errors::InvalidKeyPair::Duplicate
      puts "==> The key pair '#{key_name}' already exists. Please verify that you have the private key in ~/.ec2/#{key_name}.pem."
    end

    # Creates security group in AWS
    #
    def create_security_group
      puts "==> Creating security group..."

      @security_group = @aws_ec2.security_groups.create(security_group_name)

      @security_group.allow_ping
      @security_group.authorize_ingress(:tcp, 80)
      @security_group.authorize_ingress(:tcp, 22)

      puts "==> Successfully created security group '#{security_group_name}'"
    rescue AWS::EC2::Errors::InvalidGroup::Duplicate
      puts "==> The security group '#{security_group_name}' already exists. Please verify that it contains permissions for HTTP, SSH, and ICMP."
    end

    # Creates a new EC2 instance
    #
    # Parameters
    #   * environment: a string value of the environment (staging, production etc) that instance belongs to
    #   * config: a hash with the following keys:
    #       - image_id                    AMI for the instance.   E.g. http://cloud-images.ubuntu.com/desktop/precise/current/
    #       - instance_type               Type of the instance.   E.g.  m1.small, m1.medium etc
    #
    def create_instance(environment, config)
      puts "==> Creating EC2 instance..."

      @instance = @aws_ec2.instances.create( config.merge( { "key_name" => key_name, "security_groups" => [security_group_name] } ) )
      @instance.tag("environment", {value: environment})

      while @instance.status == :pending
        print "."
        sleep 2
      end
      puts "." # new line

      puts "==> Successfully created EC2 instance '#{@instance.id}'"
    end

    def save_to_yaml
      File.open(".stacko", "a") do |file|
        hash = { @instance.tags["environment"] => { "instance_id" => @instance.id, "ip_address" => @instance.ip_address } }
        file.write(hash.to_yaml)
      end
    end

    private

    def project
      (`basename $PWD`).gsub(/\n/, "")
    end

    def key_name
      project
    end

    def private_key_filename
      "#{ENV["HOME"]}/.ec2/#{key_name}.pem"
    end

    def security_group_name
      "#{project}-web"
    end
  end

end
