# frozen_string_literal: true

module MultiProcess
  # Receiver implementation storing process output
  # in string.
  #
  class StringReceiver < Receiver
    def received(_process, name, message)
      get(name) << message
    end

    def get(name)
      @strings ||= {}
      @strings[name.to_s] ||= +''
    end
  end
end
