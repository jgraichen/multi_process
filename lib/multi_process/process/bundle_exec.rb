# frozen_string_literal: true

class MultiProcess::Process
  # Provides functionality to wrap command in with bundle
  # execute.
  #
  module BundleExec
    def initialize(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      super %w[bundle exec] + args, opts
    end
  end
end
