require 'spec_helper'

describe MultiProcess do

  it 'should run processes' do
    reader, writer = IO.pipe

    logger = MultiProcess::Logger.new writer
    group  = MultiProcess::Group.new #receiver: logger
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb A), title: 'rubyA')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb B), title: 'rubyB')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb C), title: 'rubyC')
    group.run

    expect(reader.read_nonblock(4096).split("\n")).to match_array <<-EOF.gsub(/^\s+/, ' ').split("\n")
    rubyB | Output from B
    rubyA | Output from A
    rubyA | Output from A
    rubyC | Output from C
    rubyC | Output from C
    rubyB | Output from B
    EOF
  end

  it 'should run processes' do
    start = Time.now

    group = MultiProcess::Group.new# logger: MultiProcess::NilReceiver.new
    group << MultiProcess::Process.new(%w(ruby spec/files/sleep.rb 5000), title: 'rubyA')
    group << MultiProcess::Process.new(%w(ruby spec/files/sleep.rb 5000), title: 'rubyB')
    group << MultiProcess::Process.new(%w(ruby spec/files/sleep.rb 5000), title: 'rubyC')
    group.start
    sleep 1
    group.stop

    group.processes.each do |p|
      expect(p).to_not be_alive
    end
    expect(Time.now - start).to be < 2
  end
end
