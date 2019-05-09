require 'spec_helper'

describe MultiProcess do
  it 'should run processes' do
    reader, writer = IO.pipe

    logger = MultiProcess::Logger.new writer, collapse: false
    group  = MultiProcess::Group.new receiver: logger
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb A), title: 'rubyA')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb B), title: 'rubyBB')
    group << MultiProcess::Process.new(%w(ruby spec/files/test.rb C), title: 'rubyCCC')
    group.run

    expect(reader.read_nonblock(4096).split("\n")).to match_array <<-EOF.gsub(/^\s+\./, '').split("\n")
    .  rubyBB  | Output from B
    .   rubyA  | Output from A
    .   rubyA  | Output from A
    . rubyCCC  | Output from C
    . rubyCCC  | Output from C
    .  rubyBB  | Output from B
    EOF
  end

  it 'should run processes' do
    start = Time.now

    group = MultiProcess::Group.new receiver: MultiProcess::NilReceiver.new
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

  it 'should partition processes' do
    group = MultiProcess::Group.new partition: 4, receiver: MultiProcess::NilReceiver.new
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyA')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyB')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyC')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyD')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyE')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyF')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyG')
    group << MultiProcess::Process.new(%w(ruby sleep.rb 1), dir: 'spec/files', title: 'rubyH')

    start = Time.now
    group.run
    expect(Time.now - start).to be_within(0.3).of(2)
  end

  it 'should env processes' do
    receiver = MultiProcess::StringReceiver.new
    process  = MultiProcess::Process.new(%w(ruby spec/files/env.rb TEST), env: { 'TEST' => 'abc' }, receiver: receiver)
    process.run

    expect(receiver.get(:out)).to eq "ENV: abc\n"
  end
end
