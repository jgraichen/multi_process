module MultiProcess

  # Can create pipes and multiplex pipe content to put into
  # given IO objects e.g. multiple output from multiple
  # processes to current stdout.
  #
  class Logger < Receiver

    # Create new logger.
    #
    # @param out [IO] IO to push formatted output from
    #   default created logger pipes.
    # @param err [IO] IO to push formatted output from
    #   error sources.
    #
    def initialize(*args)
      @opts  = Hash === args.last ? args.pop : Hash.new
      @out   = args[0] || $stdout
      @err   = args[1] || $stderr

      super()
    end

    protected

    def received(process, name, line)
      case name
      when :err, :stderr
        output process, line, io: @err, delimiter: 'E>'
      when :out, :stdout
        output process, line
      when :sys
        output(process, line, delimiter: '$>') if @opts[:sys]
      end
    end

    def read(pipe)
      pipe.gets
    end

    private
    def output(process, line, opts = {})
      @mutex.synchronize do
        opts[:delimiter]   ||= ' |'
        name = if opts[:name]
          opts[:name].to_s.dup
        else
          max = @readers.values.map{|h| h[:process] ? h[:process].title.length : 0 }.max
          process ? process.title.to_s.rjust(max, ' ') : (' ' * max)
        end

        io = opts[:io] || @out
        if @last_name == name
          io.print " #{' ' * name.length} #{opts[:delimiter]} "
        else
          io.print " #{name} #{opts[:delimiter]} "
        end
        io.puts line
        io.flush

        @last_name = name
      end
    end

    class << self
      def global
        @global ||= self.new $stdout, $stderr
      end
    end
  end
end
