# frozen_string_literal: true

RSpec.describe BitcoinKernel::Transaction do
  # Genesis block coinbase transaction
  let(:genesis_coinbase_hex) do
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
    "00f2052a01000000" + # value (50 BTC = 5_000_000_000 satoshis)
    "43" + # script length
    "4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f" +
    "61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b" +
    "6bf11d5fac" + # pubkey script
    "00000000" # locktime
  end

  let(:genesis_coinbase_raw) { [genesis_coinbase_hex].pack('H*') }
  let(:genesis_coinbase_txid) { "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b" }

  describe '.from_raw' do
    it 'creates a transaction from raw data' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      expect(tx).to be_a(BitcoinKernel::Transaction)
    end

    it 'raises error for invalid data' do
      expect { described_class.from_raw("invalid") }.to raise_error(BitcoinKernel::Error)
    end
  end

  describe '#input_count' do
    it 'returns the number of inputs' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      expect(tx.input_count).to eq(1)
    end
  end

  describe '#output_count' do
    it 'returns the number of outputs' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      expect(tx.output_count).to eq(1)
    end
  end

  describe '#output_at' do
    it 'returns the output at the given index' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      output = tx.output_at(0)
      expect(output).to be_a(BitcoinKernel::TransactionOutput)
    end
  end

  describe '#outputs' do
    it 'returns all outputs' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      outputs = tx.outputs
      expect(outputs.size).to eq(1)
      expect(outputs.first).to be_a(BitcoinKernel::TransactionOutput)
    end
  end

  describe '#txid' do
    it 'returns the txid as hex string' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      expect(tx.txid).to eq(genesis_coinbase_txid)
    end
  end

  describe 'TransactionOutput' do
    it 'returns correct amount' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      output = tx.output_at(0)
      expect(output.amount).to eq(50_0000_0000) # 50 BTC in satoshis
    end

    it 'returns script pubkey' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      output = tx.output_at(0)
      expect(output.script_pubkey).to be_a(BitcoinKernel::ScriptPubkey)
    end
  end
end