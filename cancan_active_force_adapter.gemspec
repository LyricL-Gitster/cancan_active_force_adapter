# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cancan_active_force_adapter/version'

Gem::Specification.new do |spec|
  spec.name          = "cancan_active_force_adapter"
  spec.version       = CanCanActiveForceAdapter::VERSION
  spec.authors       = ["Lyric"]
  spec.email         = ["llhupp@gmail.com"]
  spec.description   = %q{Allows CanCan to work with ActiveForce}
  spec.summary       = %q{see description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'active_force', '>= 0.6.1'
  spec.add_development_dependency 'pry', '~> 0.10.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'cancancan', '~> 1.9.2'
end
