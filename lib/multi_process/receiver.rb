module MultiProcess
  # Can handle input from multiple processes and run custom
  # actions on event and output.
  #
  class Receiver
    # Request a new pipe writer for given process and name.
    #
    # @param process [ Process ] Process requesting pipe.
    # @param name [ Symbol ] Name associated to pipe e.g.
    #   `:out` or `:err`.
    #
    def pipe(process, name)
      reader, writer = IO.pipe

      Loop.instance.watch(reader) do |action, monitor|
        case action
        when :registered
          connected(process, name)
        when :ready
          received(process, name, read(monitor.io))
        when :eof
          removed(process, name)
        end
      end

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
