# Stacko

Stacko is an opinionated application deployment workflow. 

For now, Stacko can help you create and setup a Rails server on AWS in a jiffy.


## Installation

Add this line to your application's Gemfile:

    gem 'stacko'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stacko


## Usage

### 1. Create an application deployment project folder

    mkdir deployment
    
### 2. Create Gemfile in project folder

    source :rubygems
    
    gem 'rake'
    gem 'stacko'    

### 3. Create Rakefile in project folder

    require 'stacko'
    require 'stacko/tasks'
    
### 4. Initialize project folder with Chef directories

    rake stacko:init
    
### 5. Download cookbooks into project folder

    rake stacko:cookbooks_install    
    
### 6. Set up an existing server? Set up a new EC2 instance?

#### 6.1  Standalone Instance

##### 6.1.1 Create node.json

    mv nodes/node.json.sample nodes/<remote-server-ip=address>.json
    # Update details in <remote-server-ip=address>.json
    # Set app name, app git, app db name and app db password   

##### 6.1.2 Create stacko.yml

    mv config/stacko.yml.sample config/stacko.yml
    # Update details in stacko.yml
    # Set remote server ip address, username and password

#### 6.2  EC2 Instance

    TODO

### 7. Install chef-solo on server

    rake stacko:server_init[environment]
    
..where `environment` is one of the defined targets in config/stacko.yml.

### 8. Run chef-solo on server

    rake stacko:server_install[environment]

..where `environment` is one of the defined targets in config/stacko.yml.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Wait..

## License

MIT License
