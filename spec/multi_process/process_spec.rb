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
end
