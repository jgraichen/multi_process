# frozen_string_literal: true

require 'spec_helper'

describe MultiProcess do
  it 'runs processes (I)' do
    reader, writer = IO.pipe

    logger = MultiProcess::Logger.new writer, collapse: false
    group  = MultiProcess::Group.new receiver: logger
    group << MultiProcess::Process.new(%w[ruby spec/files/test.rb A], title: 'rubyA')
    group << MultiProcess::Process.new(%w[ruby spec/files/test.rb B], title: 'rubyBB')
    group << MultiProcess::Process.new(%w[ruby spec/files/test.rb C], title: 'rubyCCC')
    group.run

    expect(reader.read_nonblock(4096).split("\n")).to match_array <<-OUTPUT.gsub(/^\s+\./, '').split("\n")
    .  rubyBB  | Output from B
    .   rubyA  | Output from A
    .   rubyA  | Output from A
    . rubyCCC  | Output from C
    . rubyCCC  | Output from C
    .  rubyBB  | Output from B
    OUTPUT
  end

  it 'runs processes (II)' do
    start = Time.now

    group = MultiProcess::Group.new receiver: MultiProcess::NilReceiver.new
    group << MultiProcess::Process.new(%w[ruby spec/files/sleep.rb 5000], title: 'rubyA')
    group << MultiProcess::Process.new(%w[ruby spec/files/sleep.rb 5000], title: 'rubyB')
    group << MultiProcess::Process.new(%w[ruby spec/files/sleep.rb 5000], title: 'rubyC')
    group.start
    sleep 1
    group.stop

    group.processes.each do |p|
      expect(p).not_to be_alive
    end
    expect(Time.now - start).to be < 2
  end

  it 'starts a process added after the group has been started' do
    reader, writer = IO.pipe

    logger = MultiProcess::Logger.new writer, collapse: false
    group  = MultiProcess::Group.new receiver: logger
    group << MultiProcess::Process.new(%w[ruby spec/files/test.rb 1], title: 'ruby1')
    group.start
    group << MultiProcess::Process.new(%w[ruby spec/files/test.rb 2], title: 'ruby2')
    sleep 1
    group.stop

    expect(reader.read_nonblock(4096).split("\n")).to match_array <<-OUTPUT.gsub(/^\s+\./, '').split("\n")
    . ruby1  | Output from 1
    . ruby1  | Output from 1
    . ruby2  | Output from 2
    . ruby2  | Output from 2
    OUTPUT
  end

  it 'partitions processes' do
    group = MultiProcess::Group.new partition: 4, receiver: MultiProcess::NilReceiver.new
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyA')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyB')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyC')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyD')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyE')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyF')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyG')
    group << MultiProcess::Process.new(%w[ruby sleep.rb 1], dir: 'spec/files', title: 'rubyH')

    start = Time.now
    group.run
    expect(Time.now - start).to be_within(0.5).of(2)
  end

  it 'envs processes' do
    receiver = MultiProcess::StringReceiver.new
    process  = MultiProcess::Process.new(%w[ruby spec/files/env.rb TEST], env: {'TEST' => 'abc'}, receiver: receiver)
    process.run

    expect(receiver.get(:out)).to eq "ENV: abc\n"
  end
end
