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