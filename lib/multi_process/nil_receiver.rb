# frozen_string_literal: true

module MultiProcess
  # Receiver implementation that does nothing on every input.
  #
  class NilReceiver < Receiver
    # Do nothing.
    #
    def received(_process, _name, _message)
      nil
    end
  end
end
