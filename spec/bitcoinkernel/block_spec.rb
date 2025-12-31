# frozen_string_literal: true

RSpec.describe BitcoinKernel::Block do
  # Mainnet genesis block (raw hex)
  let(:genesis_block_hex) do
    "0100000000000000000000000000000000000000000000000000000000000000" \
    "000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa" \
    "4b1e5e4a29ab5f49ffff001d1dac2b7c01010000000100000000000000000000" \
    "00000000000000000000000000000000000000000000ffffffff4d04ffff001d" \
    "0104455468652054696d65732030332f4a616e2f32303039204368616e63656c" \
    "6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f75742066" \
    "6f722062616e6b73ffffffff0100f2052a0100000043410467e6e1ee157c96e9" \
    "7d0e8f5b0b7e8e8d8f0c2a1b3e9f8c7d6e5a4b3c2d1e0f9a8b7c6d5e4f3a2b1" \
    "c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0ac" \
    "00000000"
  end

  # Correct genesis block raw data
  let(:genesis_block_raw) do
    [
      "01000000" + # version
      "0000000000000000000000000000000000000000000000000000000000000000" + # prev block
      "3ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a" + # merkle root
      "29ab5f49" + # timestamp
      "ffff001d" + # bits
      "1dac2b7c" + # nonce
      "01" + # tx count
      # coinbase tx
      "01000000" + # version
      "01" + # input count
      "0000000000000000000000000000000000000000000000000000000000000000" + # prev tx
      "ffffffff" + # prev index
      "4d" + # script length
      "04ffff001d0104455468652054696d65732030332f4a616e2f323030392043" +
      "68616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261" +
      "696c6f757420666f722062616e6b73" + # coinbase script
      "ffffffff" + # sequence
      "01" + # output count
      "00f2052a01000000" + # value (50 BTC)
      "43" + # script length
      "4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f" +
      "61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b" +
      "6bf11d5fac" + # pubkey script
      "00000000" # locktime
    ].pack('H*')
  end

  let(:genesis_block_hash) { "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f" }

  describe '.from_raw' do
    it 'creates a block from raw data' do
      block = described_class.from_raw(genesis_block_raw)
      expect(block).to be_a(BitcoinKernel::Block)
    end

    it 'raises error for invalid data' do
      expect { described_class.from_raw("invalid") }.to raise_error(BitcoinKernel::Error)
    end
  end

  describe '#transaction_count' do
    it 'returns the number of transactions' do
      block = described_class.from_raw(genesis_block_raw)
      expect(block.transaction_count).to eq(1)
    end
  end

  describe '#transaction_at' do
    it 'returns the transaction at the given index' do
      block = described_class.from_raw(genesis_block_raw)
      tx = block.transaction_at(0)
      expect(tx).to be_a(BitcoinKernel::Transaction)
    end
  end

  describe '#transactions' do
    it 'returns all transactions' do
      block = described_class.from_raw(genesis_block_raw)
      txs = block.transactions
      expect(txs.size).to eq(1)
      expect(txs.first).to be_a(BitcoinKernel::Transaction)
    end
  end

  describe '#block_hash' do
    it 'returns the block hash' do
      block = described_class.from_raw(genesis_block_raw)
      hash = block.block_hash
      expect(hash).to be_a(BitcoinKernel::BlockHash)
    end
  end

  describe '#hash_hex' do
    it 'returns the block hash as hex string' do
      block = described_class.from_raw(genesis_block_raw)
      expect(block.block_hash.to_hex).to eq(genesis_block_hash)
    end
  end

  describe '#to_bytes' do
    it 'serializes the block back to original bytes' do
      block = described_class.from_raw(genesis_block_raw)
      expect(block.to_bytes).to eq(genesis_block_raw)
    end
  end
end