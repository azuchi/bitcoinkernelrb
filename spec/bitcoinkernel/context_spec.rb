# frozen_string_literal: true

RSpec.describe BitcoinKernel::ChainParameters do
  describe '.create' do
    it 'creates chain parameters with default (mainnet)' do
      params = described_class.create
      expect(params).to be_a(BitcoinKernel::ChainParameters)
    end

    it 'creates chain parameters for each chain type' do
      [
        BitcoinKernel::ChainType::MAINNET,
        BitcoinKernel::ChainType::TESTNET,
        BitcoinKernel::ChainType::TESTNET_4,
        BitcoinKernel::ChainType::SIGNET,
        BitcoinKernel::ChainType::REGTEST
      ].each do |chain_type|
        params = described_class.create(chain_type)
        expect(params).to be_a(BitcoinKernel::ChainParameters)
      end
    end
  end

  describe 'convenience methods' do
    it '.mainnet creates mainnet parameters' do
      expect(described_class.mainnet).to be_a(BitcoinKernel::ChainParameters)
    end

    it '.testnet creates testnet parameters' do
      expect(described_class.testnet).to be_a(BitcoinKernel::ChainParameters)
    end

    it '.testnet4 creates testnet4 parameters' do
      expect(described_class.testnet4).to be_a(BitcoinKernel::ChainParameters)
    end

    it '.signet creates signet parameters' do
      expect(described_class.signet).to be_a(BitcoinKernel::ChainParameters)
    end

    it '.regtest creates regtest parameters' do
      expect(described_class.regtest).to be_a(BitcoinKernel::ChainParameters)
    end
  end
end

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