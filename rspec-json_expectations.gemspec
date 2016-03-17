# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/json_expectations/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-json_expectations"
  spec.version       = RSpec::JsonExpectations::VERSION
  spec.authors       = ["Oleksii Fedorov"]
  spec.email         = ["waterlink000@gmail.com"]
  spec.summary       = %q{Set of matchers and helpers to allow you test your APIs responses like a pro.}
  spec.description   = ""
  spec.homepage      = "https://github.com/waterlink/rspec-json_expectations"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
