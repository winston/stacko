require 'aws-sdk'

module Stacko

  class EC2

    def initialize
      access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
      secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

      if access_key_id.nil? || secret_access_key.nil?
        raise AWS::Errors::MissingCredentialsError
      else
        @ec2 = AWS::EC2.new({access_key_id: access_key_id, secret_access_key: secret_access_key})
      end
    end

    def create_key_pair
      key_pair = @ec2.key_pairs.create(project_name)
      File.open(key_pair_filename, "w") do |file|
        file.write(key_pair.private_key)
      end
    end

    private

    def project_name
      (`basename $PWD`).gsub(/\n/, "")
    end

    def key_pair_filename
      "~/.ec2/#{project_name}.pem"
    end
  end

end

