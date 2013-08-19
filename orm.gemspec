# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orm/version'

Gem::Specification.new do |spec|
  spec.name          = "orm"
  spec.version       = Orm::VERSION
  spec.authors       = ["Noah Gibbs"]
  spec.email         = ["noah_gibbs@yahoo.com"]
  spec.description   = %q{A demo ORM.}
  spec.summary       = %q{A demo ORM.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"

  spec.add_runtime_dependency "sqlite3"
end
