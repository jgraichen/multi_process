require 'multi_process/version'
require 'childprocess'

module MultiProcess
  DEFAULT_TIMEOUT = 60

  require 'multi_process/loop'
  require 'multi_process/group'
  require 'multi_process/receiver'
  require 'multi_process/nil_receiver'
  require 'multi_process/string_receiver'
  require 'multi_process/logger'

  require 'multi_process/process'
  require 'multi_process/process/rails'
  require 'multi_process/process/bundle_exec'
end
