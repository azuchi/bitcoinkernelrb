# frozen_string_literal: true

RSpec.describe BitcoinKernel do
  describe '.disable_logging' do
    it 'disables logging without error' do
      expect { BitcoinKernel.disable_logging }.not_to raise_error
    end
  end
end
