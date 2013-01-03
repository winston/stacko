module Stacko
  module EC2Settings
    def project_name
      (`basename $PWD`).gsub(/\n/, "")
    end

    def username
      "ubuntu"
    end

    def key_name
      project_name
    end

    def security_group_name
      project_name
    end

    def private_key_file
      "#{ENV["HOME"]}/.ec2/#{key_name}.pem"
    end
  end
end
