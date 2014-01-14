module MultiProcess

  #
  #
  class Logger

    def initialize(io = nil)
      @io    = io || STDOUT
      @mutex = Mutex.new
      @readers = {}

      Thread.new do
        begin
          loop do
            io = IO.select(@readers.keys, nil, nil, 0.1)
            (io.nil? ? [] : io.first).each do |reader|
              if reader.eof?
                @readers.delete_if { |key, value| key == reader }
              else
                output_with_mutex @readers[reader], reader.read_nonblock(4096)
              end
            end
          end
        rescue Exception => ex
          puts ex.message
          puts ex.backtrace
        end
      end
    end

    def create_pipe(process)
      reader, writer = IO.pipe
      @readers[reader] = process
      writer
    end

    private
    def output_with_mutex(process, blob)
      @mutex.synchronize do
        output process, blob
      end
    end

    def output(process, blob)
      max   = @readers.values.map(&:title).map(&:length).max
      front = "(#{process.pid.to_s.rjust(5, '0')}) #{process.title.rjust(max, ' ')} | "
      blob.split(/\n+/).each do |line|
        @io.print front
        @io.puts line
      end
      @io.flush
    end
  end
end
