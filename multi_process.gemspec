# frozen_string_literal: true

require_relative 'lib/multi_process/version'

Gem::Specification.new do |spec|
  spec.name     = 'multi_process'
  spec.version  = MultiProcess::VERSION
  spec.author   = 'Jan Graichen'
  spec.email    = 'jgraichen@altimos.de'
  spec.summary  = 'Run multiple processes'
  spec.homepage = 'https://github.com/jgraichen/multi_process'
  spec.license  = 'GPLv3'

  spec.required_ruby_version = '>= 2.7'

  spec.metadata['changelog_uri'] = 'https://github.com/jgraichen/multi_process/blob/main/CHANGELOG.md'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jgraichen/multi_process.git'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'childprocess'
  spec.add_dependency 'nio4r', '~> 2.0'
end
