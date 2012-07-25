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
      access_key_id: "123"
      secret_access_key: "abc"
      ec2_endpoint: "ec2.ap-southeast-1.amazonaws.com"
    ec2:
      staging:
        image_id: "ami-1234"
        instance_type: "m1.small"
      production:
        image_id: "ami-1234"
        instance_type: "m1.large"

### 2. rake stacko:ec2:create[environment]
..where `environment` is one of the defined targets in config/stacko.yml. Using the example above, it is either "staging" or "production".

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
