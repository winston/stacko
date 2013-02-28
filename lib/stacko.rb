lib_path = File.dirname(__FILE__)

require 'aws-sdk'
require 'pp'
require "#{lib_path}/stacko/utility"
require "#{lib_path}/stacko/ec2_settings"
require "#{lib_path}/stacko/server"
require "#{lib_path}/stacko/instance"
require "#{lib_path}/stacko/ec2_instance_spawner"
require "#{lib_path}/stacko/configuration"
require "#{lib_path}/stacko/knife_operation"

module Stacko
  class << self

    def method_missing(m, *args, &block)
      @environment = args.shift
      send("_#{m}", *args, &block)
    end

    def _create_ec2_instance
      # FIXME: Verify if there alread is an instance for the environment we are trying to launch

      ec2_config = Stacko::EC2HostsConfiguration.new(File.join(".stacko"), environment)

      server = Stacko::Server.new config.global
      server.create_key_pair
      server.create_security_group

      instance = Stacko::EC2InstanceSpawner.new config, ec2_config
      instance.launch
      instance.save_config

    end

    def _install_chef
      KnifeOperation.new(instance).prepare
    end

    def _run_chef
      KnifeOperation.new(instance).cook
    end

    def _init
      KnifeOperation.new(nil).init
      FileUtils.rm_rf 'cookbooks'
      FileUtils.mkdir_p 'config'
      copy_template('stacko.yml', 'config/stacko.yml')
    end

    def _cookbooks_setup
      copy_template('rails.rb', 'roles/rails.rb')
      copy_template('Cheffile', 'Cheffile')
      render_template('node.json.erb', "nodes/#{config['env'][environment]['ip_address']}.json")
    end

    def _cookbooks_install
      system("librarian-chef install")
    end

    def _cookbooks_update
      system("librarian-chef update")
    end

    private

    def environment
      @environment
    end

    def config
      @config ||= Stacko::Configuration.new(File.join("config", "stacko.yml"), environment)
    end

    def instance
      if config.type?('ec2')
        ec2_config = Stacko::EC2HostsConfiguration.new(File.join(".stacko"), environment)
        Stacko::EC2Instance.new config, ec2_config
      else
        Stacko::StandaloneInstance.new config
      end
    end

    def template_dir
      File.join(File.dirname(__FILE__), 'generators', 'templates')
    end

    def copy_template(template_name, dest)
      if File.exist?(dest)
        puts "WARNING: File #{dest} exists, please delete it if you want to revert to defaults"
      else
        FileUtils.cp "#{File.join(template_dir, template_name)}", dest
      end
    end

    def render_template(template, dest)
      if File.exist?(dest)
        puts "WARNING: File #{dest} exists, please delete it if you want to revert to defaults"
      else
        open(File.join(template_dir, template)) do |f|
          template_text = ERB.new f.read
          open(dest, 'w') do |o|
            o.write(template_text.result(template_binding))
          end
        end
      end
    end

    def template_binding
      app = config['chef-rack_stack']
      binding
    end
  end
end
