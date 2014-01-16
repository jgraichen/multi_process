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

    # Port server should be running on.
    #
    # Default will be a free port determined when process is created.
    #
    attr_reader :port

    def initialize(opts = {})
      self.server = opts[:server] if opts[:server]
      self.port   = opts[:port]   if opts[:port]

      super *server_command, opts
    end

    def server_command
      ['rails', 'server', server, '--port', port].reject(&:nil?).map(&:to_s)
    end

    def server=(server)
      @server = server.to_s.empty? ? nil : server.to_s
    end

    def port=(port)
      @port = port.to_i == 0 ? free_port : port.to_i
    end

    def port
      @port ||= free_port
    end

    def available?
      raise ArgumentError.new "Cannot check availability for port #{port}." if port == 0

      TCPSocket.new('127.0.0.1', port).close
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
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      socket.local_address.ip_port
    ensure
      socket.close if socket
    end
  end
end
