module MultiProcess

  # Receiver implementation that does nothing on every input.
  #
  class NilReceiver < Receiver

    # Do nothing.
    #
    def received(process, name, message)
      nil
    end
  end
end
