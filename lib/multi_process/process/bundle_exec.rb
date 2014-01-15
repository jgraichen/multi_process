class MultiProcess::Process

  # Provides functionality to wrap command in with bundle
  # execute.
  #
  module BundleExec

    def initialize(*args)
      opts = Hash === args.last ? args.pop : Hash.new
      super %w(bundle exec) + args, opts
    end
  end
end
