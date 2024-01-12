# frozen_string_literal: true

require 'forwardable'
require 'timeout'

module MultiProcess
  #
  # Describes a single process that can be configured and run.
  #
  # {Process} basically is just a thin wrapper around {ChildProcess}.
  #
  class Process
    extend Forwardable

    # @!group Process

    # Process title used in e.g. logger
    attr_reader :title

    # Command as full string.
    attr_reader :command

    # ChildProcess object.
    attr_reader :childprocess

    def initialize(*args)
      args.flatten!
      opts = (args.last.is_a?(Hash) ? args.pop : {})

      @title        = opts[:title].to_s || args.first.to_s.strip.split(/\s+/, 2)[0]
      @command      = args.map {|arg| (/\A[\s"']+\z/.match?(arg) ? arg.inspect : arg).gsub '"', '\"' }.join(' ')
      @childprocess = create_childprocess(*args)

      @env          = opts[:env] if opts[:env].is_a?(Hash)
      @env_clean    = opts[:clean_env].nil? ? true : !opts[:clean_env].nil?

      self.receiver = opts[:receiver] || MultiProcess::Logger.global

      self.dir      = Dir.pwd
      self.dir      = opts[:dir].to_s if opts[:dir]
    end

    # Delegate some methods to ChildProcess.
    #
    delegate %i[exited? alive? crashed? exit_code pid] => :childprocess

    # Wait until process finished.
    #
    # If no timeout is given it will wait definitely.
    #
    # @param opts [Hash] Options.
    # @option opts [Integer] :timeout Timeout to wait in seconds.
    #
    def wait(opts = {})
      if opts[:timeout]
        childprocess.wait_for_exit opts[:timeout]
      else
        childprocess.wait
      end
    end

    # Wait until process finished.
    #
    # If no timeout is given it will wait definitely.
    #
    # @param opts [Hash] Options.
    # @option opts [Integer] :timeout Timeout to wait in seconds.
    #
    def wait!(opts = {})
      wait(opts)
      return if exit_code.zero?

      raise ::MultiProcess::ProcessError.new(self, "Process #{pid} exited with code #{exit_code}")
    end

    # Start process.
    #
    # Started processes will be stopped when ruby VM exists by hooking into
    # `at_exit`.
    #
    def start
      return false if started?

      at_exit { stop }
      receiver&.message(self, :sys, command)
      start_childprocess
      @started = true
    end

    # Stop process.
    #
    # Will call `ChildProcess#stop`.
    #
    def stop(*args)
      childprocess.stop(*args) if started?
    end

    # Check if the process is available. What available means can be defined
    # by subclasses e.g. a server process can check if its port is reachable.
    #
    # By default a process is available if `#alive?` returns true.
    #
    def available?
      alive?
    end

    # Wait until the process is available. See {#available?}.
    #
    # @param opts [Hash] Options.
    # @option opts [Integer] :timeout Timeout in seconds. Will raise
    #  Timeout::Error if timeout is reached.
    #
    def available!(opts = {})
      timeout = opts[:timeout] ? opts[:timeout].to_f : MultiProcess::DEFAULT_TIMEOUT

      Timeout.timeout timeout do
        sleep 0.2 until available?
      end
    rescue Timeout::Error
      raise Timeout::Error.new "Process #{pid} failed to start."
    end

    # Check if process was started.
    #
    def started?
      !!@started
    end

    # Start process and wait until it's finished.
    #
    # Given arguments will be passed to {#wait}.
    #
    def run(opts = {})
      start
      wait opts
    end

    # Start process and wait until it's finished.
    #
    # Given arguments will be passed to {#wait!}.
    #
    def run!(opts = {})
      start
      wait!(opts)
    end

    # @!group Working Directory

    # Working directory for child process.
    attr_reader :dir

    # Set process working directory. Only affect process if set before
    # starting.
    #
    def dir=(dir)
      @dir = ::File.expand_path(dir.to_s)
      env['PWD'] = @dir
    end

    # @!group Environment

    # Check if environment will be cleaned up for process.
    #
    # Currently that includes wrapping the process start in
    # `Bundler.with_unbundled_env` to remove bundler environment
    # variables.
    #
    def clean_env?
      !!@env_clean
    end

    # Return current environment.
    #
    def env
      @env ||= {}
    end

    # Set environment.
    #
    def env=(env)
      raise ArgumentError.new 'Environment must be a Hash.' unless env.is_a?(Hash)

      @env = env
    end

    # @!group Receiver

    # Current receiver. Defaults to `MultiProcess::Logger.global`.
    #
    attr_reader :receiver

    # Set receiver that should receive process output.
    #
    def receiver=(receiver)
      if @receiver
        childprocess.io.stdout.close
        childprocess.io.stderr.close
      end

      childprocess.io.stdout = receiver.pipe(self, :out) if receiver
      childprocess.io.stderr = receiver.pipe(self, :err) if receiver
      @receiver = receiver
    end

    private

    # Create child process.
    #
    def create_childprocess(*args)
      ChildProcess.new(*args.flatten)
    end

    # Start child process.
    #
    # Can be used to hook in subclasses and modules.
    #
    def start_childprocess
      env.each {|k, v| childprocess.environment[k.to_s] = v.to_s }
      childprocess.cwd = dir

      if clean_env?
        Bundler.with_unbundled_env { childprocess.start }
      else
        childprocess.start
      end
    end
  end
end
