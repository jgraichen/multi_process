# frozen_string_literal: true

module MultiProcess
  RSpec.describe self do
    it 'runs processes (I)' do
      reader, writer = IO.pipe

      logger = Logger.new(writer, collapse: false)
      group = Group.new(receiver: logger)

      group << Process.new(%w[ruby spec/files/test.rb A], title: 'rubyA')
      group << Process.new(%w[ruby spec/files/test.rb B], title: 'rubyBB')
      group << Process.new(%w[ruby spec/files/test.rb C], title: 'rubyCCC')

      group.run

      expect(reader.read_nonblock(4096).lines)
        .to match_array <<~OUTPUT.gsub(/^\./, '').lines
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

      group = Group.new(receiver: NilReceiver.new)

      ('A'..'C').collect {|letter| "ruby#{letter}" }.each do |title|
        group << Process.new(%w[ruby spec/files/sleep.rb 5000], title: title)
      end

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

      logger = Logger.new(writer, collapse: false)
      group = Group.new(receiver: logger)
      group << Process.new(%w[ruby spec/files/test.rb 1], title: 'ruby1')
      group.start
      group << Process.new(%w[ruby spec/files/test.rb 2], title: 'ruby2')
      group.wait

      expect(reader.read_nonblock(4096).lines)
        .to match_array <<~OUTPUT.gsub(/^\./, '').lines
          . ruby1  | Output from 1
          . ruby1  | Output from 1
          . ruby2  | Output from 2
          . ruby2  | Output from 2
        OUTPUT
    end

    it 'partitions processes' do
      group = Group.new(partition: 4, receiver: NilReceiver.new)

      ('A'..'H').collect {|letter| "ruby#{letter}" }.each do |title|
        group << Process.new(
          %w[ruby sleep.rb 1],
          dir: 'spec/files',
          title: title,
        )
      end

      start = Time.now
      group.run
      expect(Time.now - start).to be_within(0.5).of(2)
    end

    it 'envs processes' do
      receiver = StringReceiver.new

      process = Process.new(
        %w[ruby spec/files/env.rb TEST],
        env: {'TEST' => 'abc'},
        receiver: receiver,
      )
      process.run

      expect(receiver.get(:out)).to eq "ENV: abc\n"
    end
  end
end
