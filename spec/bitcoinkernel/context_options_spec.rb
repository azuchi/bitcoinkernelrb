# frozen_string_literal: true

RSpec.describe BitcoinKernel::ContextOptions do
  describe '.create' do
    it 'creates context options' do
      options = described_class.create
      expect(options).to be_a(BitcoinKernel::ContextOptions)
    end
  end

  describe '#set_chainparams' do
    it 'sets chain parameters and returns self' do
      options = described_class.create
      params = BitcoinKernel::ChainParameters.regtest
      result = options.set_chainparams(params)
      expect(result).to eq(options)
    end
  end
end