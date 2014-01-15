module MultiProcess

  # Store and run a group of processes.
  #
  class Group

    # Return list of processes.
    attr_reader :processes

    # Receiver all processes in group should use.
    #
    # If changed only affect new added processes.
    #
    attr_accessor :receiver

    # Partition size.
    attr_reader :partition

    # Create new process group.
    #
    # @param opts [ Hash ] Options
    # @option otps [ Receiver ] :receiver Receiver to use for new added
    #   processes. Defaults to `MultiProcess::Logger.global`.
    #
    def initialize(opts = {})
      @processes = []
      @receiver  = opts[:receiver] ? opts[:receiver] : MultiProcess::Logger.global
      @partition = opts[:partition] ? opts[:partition].to_i : 0
      @mutex     = Mutex.new
    end

    # Add new process or list of processes.
    #
    # If group was already started added processes will also be started.
    #
    # @param process [Process, Array<Process>] New process or processes.
    #
    def <<(process)
      Array(process).flatten.each do |process|
        processes << process
        process.receiver = receiver

        if started?
          start process
        end
      end
    end

    # Start all process in group.
    #
    # Call blocks until all processes are started.
    #
    # @param opts [ Hash ] Options.
    # @option opts [ Integer ] :delay Delay in seconds between starting processes.
    #
    def start(opts = {})
      processes.each do |process|
        unless process.started?
          process.start
          sleep opts[:delay] if opts[:delay]
        end
      end
    end

    # Check if group was already started.
    #
    # @return [ Boolean ] True if group was already started.
    #
    def started?
      processes.any? &:started?
    end

    # Stop all processes.
    #
    def stop
      processes.each do |process|
        process.stop
      end
    end

    # Wait until all process terminated.
    #
    # @param opts [ Hash ] Options.
    # @option opts [ Integer ] :timeout Timeout in seconds to wait before
    #   raising {Timeout::Error}.
    #
    def wait(opts = {})
      opts[:timeout] ||= 30

      ::Timeout::timeout(opts[:timeout]) do
        processes.each{|p| p.wait}
      end
    end

    # Start all process and wait for them to terminate.
    #
    # Given options will be passed to {#start} and {#wait}.
    # {#start} will only be called if partition is zero.
    #
    # If timeout is given process will be terminated using {#stop}
    # when timeout error is raised.
    #
    def run(opts = {})
      if partition > 0
        threads = Array.new
        partition.times do
          threads << Thread.new do
            while (process = next_process)
              process.run
            end
          end
        end
        threads.each &:join
      else
        start opts
        wait opts
      end
    ensure
      stop
    end

    # Check if group is alive e.g. if at least on process is alive.
    #
    # @return [ Boolean ] True if group is alive.
    #
    def alive?
      processes.any? &:alive?
    end

    # Check if group is available. The group is available if all
    # processes are available.
    #
    def available?
      !processes.any?{|p| !p.available? }
    end

    # Wait until group is available. This implies waiting until
    # all processes in group are available.
    #
    # Processes will not be stopped if timeout occurs.
    #
    # @param opts [ Hash ] Options.
    # @option opts [ Integer ] :timeout Timeout in seconds to wait for processes
    #   to become available. Defaults to {MultiProcess::DEFAULT_TIMEOUT}.
    #
    def available!(opts = {})
      timeout = opts[:timeout] ? opts[:timeout].to_i : MultiProcess::DEFAULT_TIMEOUT

      Timeout.timeout timeout do
        processes.each{|p| p.available! }
      end
    end

    private
    def next_process
      @mutex.synchronize do
        @index ||= 0
        @index += 1
        processes[@index - 1]
      end
    end
  end
end
