# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-cli"
  spec.version       = RSpec::Cli::VERSION
  spec.authors       = ["Sia. S."]
  spec.email         = ["sia.s.saj@gmail.com"]
  spec.summary       = "rspec-cli-#{RSpec::Cli::VERSION}"
  spec.description   = "A set of tools to test programs on the command line"
  spec.homepage      = "https://github.com/quazimodo/rspec-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"

end
