require 'spec_helper'

describe MultiProcess do

  it 'should run processes' do
    logger = MultiProcess::Logger.new $stdout
    group = MultiProcess::Group.new logger: logger
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb A), title: 'rubyA')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb B), title: 'rubyB')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb C), title: 'rubyC')
    group.run
  end
end
