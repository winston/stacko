# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stacko/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Winston"]
  gem.email         = ["winston.yongwei@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stacko"
  gem.require_paths = ["lib"]
  gem.version       = Stacko::VERSION

  gem.add_dependency "aws-sdk", ">= 1.5.7"

  gem.add_development_dependency "bundler", ">= 1.1.4"
  gem.add_development_dependency "rspec"  , ">= 2.11.0"
end
