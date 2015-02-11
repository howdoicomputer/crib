# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crib/version'

Gem::Specification.new do |spec|
  spec.name          = 'crib'
  spec.version       = Crib::VERSION.dup
  spec.authors       = ['Rafal Chmiel']
  spec.email         = ['rafalmarekchmiel@gmail.com']
  spec.summary       = 'A dynamic way of quickly exploring REST APIs.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/rafalchmiel/crib'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_runtime_dependency 'sawyer', '~> 0.6'
  spec.add_development_dependency 'bundler', '~> 1.6'
end
