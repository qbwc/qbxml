# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qbxml/version'

Gem::Specification.new do |gem|
  gem.name          = "qbxml"
  gem.version       = Qbxml::VERSION
  gem.authors       = ["Alex Skryl", "Jason Barnabe"]
  gem.email         = ["rut216@gmail.com", "jason.barnabe@gmail.com"]
  gem.description   = %q{Quickbooks XML Parser}
  gem.summary       = %q{Quickbooks XML Parser and Validation Tool}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('activesupport', '>= 4.1.0')
  gem.add_dependency('nokogiri', '~> 1.5')
  gem.add_dependency('builder', '~> 3.0')

  gem.add_development_dependency('pry')
  gem.add_development_dependency('pry-nav')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('simplecov')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('appraisal')
end
