# frozen_string_literal: true

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
      @opts  = args.last.is_a?(Hash) ? args.pop : {}
      @out   = args[0] || $stdout
      @err   = args[1] || $stderr

      @colwidth = 0

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

    def connected(process, _)
      @colwidth = [process.title.to_s.length, @colwidth].max
    end

    def read(pipe)
      pipe.gets
    end

    def collapse?
      @opts[:collapse].nil? || @opts[:collapse]
    end

    private

    def output(process, line, opts = {})
      opts[:delimiter] ||= ' |'
      name = if opts[:name]
               opts[:name].to_s.dup
             elsif process
               process.title.to_s.rjust(@colwidth, ' ')
             else
               (' ' * @colwidth)
             end

      io = opts[:io] || @out
      if @last_name == name && collapse?
        io.print " #{' ' * name.length} #{opts[:delimiter]} "
      else
        io.print " #{name} #{opts[:delimiter]} "
      end
      io.puts line
      io.flush

      @last_name = name
    end

    class << self
      def global
        @global ||= new $stdout, $stderr
      end
    end
  end
end
