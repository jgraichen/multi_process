# frozen_string_literal: true

class MultiProcess::Process
  # Provides functionality for a process that is a rails server
  # process.
  #
  # Include this module if required.
  #
  # Functions include port generation, default server command and
  # availability check based on if server socket is reachable.
  #
  module Rails
    # Server wrapper given as argument to `server` action.
    #
    attr_reader :server

    def initialize(opts = {})
      self.server = opts[:server] if opts[:server]
      self.port   = opts[:port]   if opts[:port]

      super(*server_command, opts)
    end

    def server_command
      ['rails', 'server', server, '--port', port].compact.map(&:to_s)
    end

    def server=(server)
      @server = server.to_s.empty? ? nil : server.to_s
    end

    def port=(port)
      port = Integer(port)
      @port = port.zero? ? free_port : port
    end

    def port
      @port ||= free_port
    end

    def available?
      raise ArgumentError.new "Cannot check availability for port #{port}." if port.zero?

      TCPSocket.new('localhost', port).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      false
    end

    # Load environment options from initialize options.
    #
    def configure(opts)
      super
      puts 'Configure RAILS'
      self.dir = Dir.pwd
      self.dir = opts[:dir].to_s if opts[:dir]
    end

    def start_childprocess(*args)
      Dir.chdir(dir) { super }
    end

    private

    def free_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp('localhost', 0))
      socket.local_address.ip_port
    ensure
      socket&.close
    end
  end
end
