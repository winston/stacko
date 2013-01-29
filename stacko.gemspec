# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stacko/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Winston"]
  gem.email         = ["winston.yongwei@gmail.com"]
  gem.description   = %q{Stacko can help you create and setup a Rails server on AWS in a jiffy}
  gem.summary       = %q{Stacko can help you create and setup a Rails server on AWS in a jiffy}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stacko"
  gem.require_paths = ["lib"]
  gem.version       = Stacko::VERSION

  gem.add_dependency "librarian"          , ">= 0.0.26"
  gem.add_dependency "knife-solo"         , ">= 0.1.0"
  gem.add_dependency "aws-sdk"            , ">= 1.8.1.1"

  gem.add_development_dependency "bundler", ">= 1.2.3"
  gem.add_development_dependency "rspec"  , ">= 2.12.0"
  gem.add_development_dependency "debugger"
end
