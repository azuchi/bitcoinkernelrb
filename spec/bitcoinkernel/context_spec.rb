# frozen_string_literal: true

RSpec.describe BitcoinKernel::Context do
  describe '.create' do
    it 'creates context with default options' do
      context = described_class.create
      expect(context).to be_a(BitcoinKernel::Context)
    end

    it 'creates context with custom options' do
      options = BitcoinKernel::ContextOptions.create
      params = BitcoinKernel::ChainParameters.regtest
      options.set_chainparams(params)
      context = described_class.create(options)
      expect(context).to be_a(BitcoinKernel::Context)
    end
  end

  describe '#interrupt' do
    it 'returns a boolean' do
      context = described_class.create
      result = context.interrupt
      expect([true, false]).to include(result)
    end
  end
end