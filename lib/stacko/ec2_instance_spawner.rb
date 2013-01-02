module Stacko
  class EC2InstanceSpawner
    include Stacko::Settings

    # Initialize
    #
    # Parameters
    #   * config: a hash with the following keys:
    #       - access_key_id               AWS access key id.      E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
    #       - secret_access_key           AWS secret access key.  E.g. https://portal.aws.amazon.com/gp/aws/securityCredentials
    #       - ec2_endpoint [optional]     AWS region.             Defaults to "ec2.us-east-1.amazonaws.com".
    #
    def initialize(config)
      @config = config
      @aws_ec2 = AWS::EC2.new(@config.global)
    end

    # Creates a new EC2 instance
    #
    # Parameters
    #   * environment: a string value of the environment (staging, production etc)
    #   * config: a hash with the following keys:
    #       - image_id                    AMI for the instance.   E.g. http://cloud-images.ubuntu.com/desktop/precise/current/
    #       - instance_type               Type of the instance.   E.g.  m1.small, m1.medium etc
    #
    def launch
      puts "==> Creating EC2 instance..."

      @instance = @aws_ec2.instances.create( @config.env.merge( { "key_name" => key_name, "security_groups" => [security_group_name] } ) )
      @instance.tag("environment", {value: @config.environment})

      while @instance.status == :pending
        print "."
        sleep 2
      end

      # Sleep for 30 more seconds
      15.times do
        print "."
        sleep 2
      end
      puts "." # new line

      puts "==> Successfully created EC2 instance '#{@instance.id}'"
    end

    def to_hash
      { @instance.tags["environment"] => { "instance_id" => @instance.id, "ip_address" => @instance.ip_address } }
    end

  end
end
