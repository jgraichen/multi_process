module MultiProcess

  # Receiver implementation storing process output
  # in string.
  #
  class StringReceiver < Receiver

    def received(process, name, message)
      get(name) << message
    end

    def get(name)
      @strings ||= Hash.new
      @strings[name.to_s] ||= String.new
    end
  end
end
