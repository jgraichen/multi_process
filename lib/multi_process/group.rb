module MultiProcess

  #
  #
  #
  class Group
    attr_reader :processes, :logger

    def initialize(opts = {})
      @processes = []
      @logger = opts[:logger] ? opts[:logger] : MultiProcess::Logger.new
    end

    def <<(process)
      processes << process

      if started?
        start process
      end
    end

    def start
      processes.each do |process|
        unless process.started?
          process.start logger
        end
      end
    end

    def started?
      processes.any? &:started?
    end

    def stop
      processes.each do |process|
        unless process.alive?
          process.stop
        end
      end
    end

    def wait(opts = {})
      opts[:timeout] ||= 30

      ::Timeout::timeout(opts[:timeout]) do
        processes.each{|p| p.wait}
      end
    end

    def run(opts = {})
      start
      wait opts
      stop
    end

    def alive?
      processes.any? &:alive?
    end
  end
end
