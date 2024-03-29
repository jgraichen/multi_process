# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MultiProcess::Process do
  subject(:process) { MultiProcess::Process.new(command) }

  describe '#run!' do
    context 'with failing command' do
      let(:command) { %w[ruby spec/files/fail.rb] }

      it 'does raise an error' do
        expect { process.run! }.to raise_error(MultiProcess::ProcessError, /Process \d+ exited with code 1/)
      end
    end
  end

  describe '#available!' do
    context 'when timeout is reached' do
      let(:command) { %w[ruby spec/files/sleep.rb 0.2] }

      it 'does raise an error' do
        process.run!

        expect { process.available! timeout: 0.1 }.to raise_error(Timeout::Error, /Process \d+ failed to start/)
      end
    end
  end
end
