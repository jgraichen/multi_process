# frozen_string_literal: true

module MultiProcess
  class Error < StandardError; end

  class ProcessError < Error
    attr_reader :process

    def initialize(process, *args, **kwargs)
      @process = process
      super(*args, **kwargs)
    end
  end
end
