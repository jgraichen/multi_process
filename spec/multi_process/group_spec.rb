# frozen_string_literal: true

module MultiProcess
  RSpec.describe Group do
    subject(:group) { described_class.new }

    before do
      group << Process.new(command)
    end

    describe '#run!' do
      context 'with failing command' do
        let(:command) { %w[ruby spec/files/fail.rb] }

        it 'does raise an error' do
          expect { group.run! }.to raise_error(ProcessError, /Process \d+ exited with code 1/)
        end
      end

      context 'with partition and failing command' do
        subject(:group) { Group.new(partition: 1) }

        let(:command) { %w[ruby spec/files/fail.rb] }

        it 'does raise an error' do
          expect { group.run! }.to raise_error(ProcessError, /Process \d+ exited with code 1/)
        end
      end
    end
  end
end
