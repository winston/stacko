# Stacko

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'stacko'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stacko

## Usage

### 1. Create config/stacko.yml

    aws:
      access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
      secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
      ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"
    env:
      staging:
        image_id: "ami-02581950"
        instance_type: "t1.micro"
      production:
        image_id: "ami-02581950"
        instance_type: "t1.micro"

# FIXME: I am assuming that only Ubuntu AMIs are used

### 2. rake stacko:ec2:create[environment]
..where `environment` is one of the defined targets in config/stacko.yml. Using the example above, it is either "staging" or "production".

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes
create  env
destroy env

write better .stacko / gitignore .stacko
chef instance

status[environment]
detail[environment]

