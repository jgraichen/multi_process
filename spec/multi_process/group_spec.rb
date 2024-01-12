# frozen_string_literal: true

RSpec.describe MultiProcess::Group do
  subject(:group) { MultiProcess::Group.new }

  before do
    group << MultiProcess::Process.new(command)
  end

  describe '#run!' do
    context 'with failing command' do
      let(:command) { %w[ruby spec/files/fail.rb] }

      it 'does raise an error' do
        expect { group.run! }.to raise_error(MultiProcess::ProcessError, /Process \d+ exited with code 1/)
      end
    end

    context 'with partition and failing command' do
      subject(:group) { MultiProcess::Group.new(partition: 1) }

      let(:command) { %w[ruby spec/files/fail.rb] }

      it 'does raise an error' do
        expect { group.run! }.to raise_error(MultiProcess::ProcessError, /Process \d+ exited with code 1/)
      end
    end
  end
end
