module Stacko
  class Server
    include Stacko::EC2Settings

    # Initialize
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

    def create_key_pair
      puts "==> Creating key pair..."

      @key_pair = @aws_ec2.key_pairs.create(key_name)
      File.open(private_key_file, "w", 0600) do |file|
        file.write(@key_pair.private_key)
      end

      puts "==> Successfully created key pair '#{key_name}'"
    rescue AWS::EC2::Errors::InvalidKeyPair::Duplicate
      puts "==> The key pair '#{key_name}' already exists. Please verify that you have the private key in #{private_key_file}."
    end

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

  end
end
