# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'workaholic/version'

Gem::Specification.new do |spec|
  spec.name          = "workaholic"
  spec.version       = Workaholic::VERSION
  spec.authors       = ["Vasily Reys"]
  spec.email         = ["reys.vasily@gmail.com"]
  spec.summary       = %q{Build bullet proof workers for your application}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/vreys/workaholic"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency "celluloid"
end
