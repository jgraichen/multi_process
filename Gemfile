# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in multi_process.gemspec
gemspec

gem 'rake'
gem 'rake-release', '~> 1.3'
gem 'rspec', '~> 3.11'

group :development do
  gem 'rubocop-config', github: 'jgraichen/rubocop-config', tag: 'v14'
end

group :test do
  gem 'rspec-github'
  gem 'simplecov'
  gem 'simplecov-cobertura'
end
