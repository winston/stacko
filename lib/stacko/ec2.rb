require 'aws-sdk'

module Stacko

  class EC2

    class << self
      def create
        # Puts statement for status!
      end

      def destroy
        # read .stacko
        # destroy key pair
        # destroy security group
        # destroy instance
        # destroy .stacko
      end
    end

    def initialize
      # Use Rails Env

      access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
      secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
      ec2_endpoint      = ENV["EC2_ENDPOINT"]

      if access_key_id.nil? || secret_access_key.nil?
        raise AWS::Errors::MissingCredentialsError
      else
        @ec2 = AWS::EC2.new({access_key_id: access_key_id, secret_access_key: secret_access_key, ec2_endpoint: ec2_endpoint})
      end
    end

    def create_key_pair
      # Handle existing key pair

      key_pair = @ec2.key_pairs.create(key_name)
      File.open(private_key_filename, "w") do |file|
        file.write(key_pair.private_key)
      end
    end

    def create_security_group
      # Handle existing key pair

      security_group = @ec2.security_groups.create(security_group_name)

      security_group.allow_ping
      security_group.authorize_ingress(:tcp, 80)
      security_group.authorize_ingress(:tcp, 22)
    end

    def create_instance(image_id, instance_type)
      # default AMI? default instance type?

      @ec2.instances.create({
        image_id: image_id,
        instance_type: instance_type,
        key_name: key_name,
        security_groups: security_group_name
      })

      # Wait for running status

      # Tag instance (for easy retrieval)

      # Print out details

      # Save details to .stacko
    end

    def chef_instance
      # knife prepare
      # knife cook
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
