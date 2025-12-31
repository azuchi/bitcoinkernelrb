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

  describe '#input_at' do
    it 'returns the input at the given index' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      input = tx.input_at(0)
      expect(input).to be_a(BitcoinKernel::TransactionInput)
    end
  end

  describe '#inputs' do
    it 'returns all inputs' do
      tx = described_class.from_raw(genesis_coinbase_raw)
      inputs = tx.inputs
      expect(inputs.size).to eq(1)
      expect(inputs.first).to be_a(BitcoinKernel::TransactionInput)
    end
  end

  describe 'TransactionInput' do
    # Hal Finney transaction (block 170) - spends block 9 coinbase
    let(:hal_finney_tx_hex) do
      "0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423edce25857fcd3704000000004847304402204e45e16932b8af514961a1d3a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07de4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac00286bee0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000"
    end
    let(:hal_finney_tx_raw) { [hal_finney_tx_hex].pack('H*') }
    # Block 9 coinbase txid (the transaction being spent)
    let(:block9_coinbase_txid) { "0437cd7f8525ceed2324359c2d0ba26006d92d856a9c20fa0241106ee5a597c9" }

    it 'returns out_point with correct txid' do
      tx = described_class.from_raw(hal_finney_tx_raw)
      input = tx.input_at(0)
      out_point = input.out_point
      expect(out_point.txid).to eq(block9_coinbase_txid)
    end

    it 'returns out_point with correct index' do
      tx = described_class.from_raw(hal_finney_tx_raw)
      input = tx.input_at(0)
      out_point = input.out_point
      expect(out_point.index).to eq(0)
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