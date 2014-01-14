require 'active_support/core_ext/module/delegation'

module MultiProcess

  #
  #
  class Process
    attr_reader :title, :command, :child

    def initialize(*args)
      args.flatten!
      opts = (Hash === args.last ? args.pop : {})
      @title   = opts[:title] || args.first.to_s.strip.split(/\s+/, 2)[0]
      @command = args.map{ |arg| (arg =~ /\A[\s"']+\z/ ? arg.inspect : arg).gsub '"', '\"' }.join(' ')
      @child   = ChildProcess.new *args.flatten
    end

    delegate :stop, :exited?, :alive?, :crashed?,
      :exit_code, :pid, to: :child

    def wait(opts = {})
      if opts[:timeout]
        child.wait_for_exit opts[:timeout]
      else
        child.wait
      end
    end

    def start(logger)
      pipe = logger.create_pipe(self)
      child.io.stdout = pipe
      child.io.stderr = pipe
      child.start

      @started = true
    end

    def started?
      !!@started
    end
  end
end
