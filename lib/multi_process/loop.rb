require 'nio'

module MultiProcess
  class Loop
    def initialize
      @selector = ::NIO::Selector.new

      Thread.new do
        loop do
          @selector.select(30.0) do |monitor|
            if monitor.io.eof?
              @selector.deregister(monitor.io)
              monitor.value.call(:eof, monitor)
            else
              monitor.value.call(:ready, monitor)
            end
          end

          # Wait very short time to allow scheduling another thread
          sleep(0.001)
        end
      end
    end

    def watch(io, &block)
      @selector.wakeup
      @selector.register(io, :r).tap do |monitor|
        monitor.value = block
        monitor.value.call(:registered, monitor)
      end
    end

    class << self
      def instance
        @instance ||= new
      end
    end
  end
end
