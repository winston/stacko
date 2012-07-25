require 'aws-sdk'

module Stacko

  class EC2

    class << self

      # Runs through the steps for creating a new EC2 instance
      #
      # Parameters
      #   * aws_config: a hash with the following keys:
      #       - access_key_id       AWS access key id.      E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
      #       - secret_access_key   AWS secret access key.  E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
      #       - ec2_endpoint        AWS region.             Defaults to "ec2.us-east-1.amazonaws.com".
      #   * ec2__config: a hash with the following keys:
      #       - image_id            AMI for the instance.   E.g. http://cloud-images.ubuntu.com/desktop/precise/current/
      #       - instance_type       Type of the instance.   E.g.  m1.small, m1.medium etc
      #
      def create(aws_config, ec2_config)
        # FIXME: Raise error for bad configs

        stack = Stacko::EC2.new(aws_config)
        stack.create_key_pair
        stack.create_security_group
        stack.create_instance(ec2_config)
      end

      def destroy
        # read .stacko
        # destroy key pair
        # destroy security group
        # destroy instance
        # destroy .stacko
      end

      def find
        # find for env
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
      @aws_ec2 = AWS::EC2.new(config)
    end

    # Creates key pair in AWS
    #
    def create_key_pair
      puts "==> Creating key pair..."

      key_pair = @aws_ec2.key_pairs.create(key_name)
      File.open(private_key_filename, "w") do |file|
        file.write(key_pair.private_key)
      end

      puts "==> Successfully created key pair '#{key_name}'"
    rescue AWS::EC2::Errors::InvalidKeyPair::Duplicate
      puts "==> The key pair '#{key_name}' already exists. Please verify that you have the private key in ~/.ec2/#{key_name}.pem."
    end

    # Creates security group in AWS
    #
    def create_security_group
      puts "==> Creating security group..."

      security_group = @aws_ec2.security_groups.create(security_group_name)

      security_group.allow_ping
      security_group.authorize_ingress(:tcp, 80)
      security_group.authorize_ingress(:tcp, 22)

      puts "==> Successfully created security group '#{security_group_name}'"
    rescue AWS::EC2::Errors::InvalidGroup::Duplicate
      puts "==> The security group '#{security_group_name}' already exists. Please verify that it contains permissions for HTTP, SSH, and ICMP."
    end

    # Creates a new EC2 instance
    #
    # Parameters
    #   * config: a hash with the following keys:
    #       - image_id                    AMI for the instance.   E.g. http://cloud-images.ubuntu.com/desktop/precise/current/
    #       - instance_type               Type of the instance.   E.g.  m1.small, m1.medium etc
    #
    def create_instance(config)
      puts "==> Creating EC2 instance..."

      instance = @aws_ec2.instances.create( config.merge( { "key_name" => key_name, "security_groups" => security_group_name } ) )

      while instance.status == :pending
        print "."
        sleep 2
      end
      puts "." # For new line

      save_to_yaml(instance.id)

      puts "==> Successfully created EC2 instance '#{instance.id}'"
    end

    def chef_instance
      # knife prepare + cook
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

    def save_to_yaml(instance_id)
      File.open(".stacko", "w") do |file|
        file.write(instance_id)
      end
    end
  end

end
