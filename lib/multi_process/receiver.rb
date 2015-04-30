module MultiProcess
  # Can handle input from multiple processes and run custom
  # actions on event and output.
  #
  class Receiver
    # Mutex to synchronize operations.
    #
    attr_reader :mutex

    def initialize
      @mutex   = Mutex.new
      @readers = {}

      Thread.new do
        begin
          loop do
            io = IO.select(@readers.keys, nil, nil, 0.1)
            (io.nil? ? [] : io.first).each do |reader|
              op = @readers[reader]

              if reader.eof?
                @readers.delete_if { |key, _value| key == reader }
                removed op[:process], op[:name]
              else
                received op[:process], op[:name], read(reader)
              end
            end
          end
        rescue Exception => ex
          puts ex.message
          puts ex.backtrace
        end
      end
    end

    # Request a new pipe writer for given process and name.
    #
    # @param process [ Process ] Process requesting pipe.
    # @param name [ Symbol ] Name associated to pipe e.g.
    #   `:out` or `:err`.
    #
    def pipe(process, name)
      reader, writer = IO.pipe
      @readers[reader] = { name: name, process: process }
      connected process, name
      writer
    end

    # Send a custom messages.
    #
    def message(process, name, message)
      received process, name, message
    end

    protected

    # Will be called when content is received for given
    # process and name.
    #
    # Must be overridden by subclass.
    #
    def received(_process, _name, _message)
      fail NotImplementedError.new 'Subclass responsibility.'
    end

    # Read content from pipe. Can be used to provide custom reading
    # like reading lines instead of byte ranges.
    #
    # Should be non blocking.
    #
    def read(reader)
      reader.read_nonblock 4096
    end

    # Called after pipe for process and name was removed because it
    # reached EOF.
    #
    def removed(_process, _name)
    end

    # Called after new pipe for process and name was created.
    #
    def connected(_process, _name)
    end
  end
end
