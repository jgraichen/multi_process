# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_process/version'

Gem::Specification.new do |spec|
  spec.name          = 'multi_process'
  spec.version       = MultiProcess::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = ['jg@altimos.de']
  spec.summary       = 'Handle multiple child processes.'
  spec.description   = 'Handle multiple child processes.'
  spec.homepage      = 'https://github.com/jgraichen/multi_process'
  spec.license       = 'GPLv3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 3.1'
  spec.add_runtime_dependency 'childprocess'
  spec.add_runtime_dependency 'nio4r', '~> 2.0'

  spec.add_development_dependency 'bundler'
end
