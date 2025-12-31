# frozen_string_literal: true

RSpec.describe BitcoinKernel::BlockHash do
  let(:genesis_block_hash_hex) { "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f" }
  let(:genesis_block_hash_bytes) { [genesis_block_hash_hex].pack('H*').reverse }

  describe '.from_bytes' do
    it 'creates a block hash from 32 bytes' do
      hash = described_class.from_bytes(genesis_block_hash_bytes)
      expect(hash).to be_a(BitcoinKernel::BlockHash)
    end

    it 'raises error for invalid length' do
      expect { described_class.from_bytes("short") }.to raise_error(BitcoinKernel::Error)
    end
  end

  describe '.from_hex' do
    it 'creates a block hash from hex string' do
      hash = described_class.from_hex(genesis_block_hash_hex)
      expect(hash).to be_a(BitcoinKernel::BlockHash)
    end
  end

  describe '#to_bytes' do
    it 'returns 32-byte binary string' do
      hash = described_class.from_hex(genesis_block_hash_hex)
      bytes = hash.to_bytes
      expect(bytes.bytesize).to eq(32)
      expect(bytes).to eq(genesis_block_hash_bytes)
    end
  end

  describe '#to_hex' do
    it 'returns hex string in little-endian format' do
      hash = described_class.from_hex(genesis_block_hash_hex)
      expect(hash.to_hex).to eq(genesis_block_hash_hex)
    end
  end

  describe 'round trip' do
    it 'preserves hash through from_hex and to_hex' do
      hash = described_class.from_hex(genesis_block_hash_hex)
      expect(hash.to_hex).to eq(genesis_block_hash_hex)
    end

    it 'preserves hash through from_bytes and to_bytes' do
      hash = described_class.from_bytes(genesis_block_hash_bytes)
      expect(hash.to_bytes).to eq(genesis_block_hash_bytes)
    end
  end

  describe '#==' do
    let(:block_170_hash_hex) { "00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee" }

    it 'returns true for equal block hashes' do
      hash1 = described_class.from_hex(genesis_block_hash_hex)
      hash2 = described_class.from_hex(genesis_block_hash_hex)
      expect(hash1 == hash2).to be true
    end

    it 'returns false for different block hashes' do
      hash1 = described_class.from_hex(genesis_block_hash_hex)
      hash2 = described_class.from_hex(block_170_hash_hex)
      expect(hash1 == hash2).to be false
    end

    it 'returns false when comparing with non-BlockHash' do
      hash = described_class.from_hex(genesis_block_hash_hex)
      expect(hash == genesis_block_hash_hex).to be false
      expect(hash == nil).to be false
    end
  end
end