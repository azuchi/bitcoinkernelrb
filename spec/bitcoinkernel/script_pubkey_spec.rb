# frozen_string_literal: true

RSpec.describe BitcoinKernel::ScriptPubkey do
  # P2PKH script: OP_DUP OP_HASH160 <pubkey_hash> OP_EQUALVERIFY OP_CHECKSIG
  let(:p2pkh_script_hex) { "76a914" + "89abcdefabbaabbaabbaabbaabbaabbaabbaabba" + "88ac" }
  let(:p2pkh_script_raw) { [p2pkh_script_hex].pack('H*') }

  # Genesis coinbase output script (P2PK)
  let(:genesis_p2pk_script_hex) do
    "41" + # push 65 bytes
    "04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f" +
    "61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b" +
    "6bf11d5f" +
    "ac" # OP_CHECKSIG
  end
  let(:genesis_p2pk_script_raw) { [genesis_p2pk_script_hex].pack('H*') }

  describe '.from_raw' do
    it 'creates a script pubkey from raw bytes' do
      script = described_class.from_raw(p2pkh_script_raw)
      expect(script).to be_a(BitcoinKernel::ScriptPubkey)
    end

    it 'creates a script pubkey from genesis P2PK script' do
      script = described_class.from_raw(genesis_p2pk_script_raw)
      expect(script).to be_a(BitcoinKernel::ScriptPubkey)
    end

    it 'creates empty script' do
      script = described_class.from_raw("")
      expect(script).to be_a(BitcoinKernel::ScriptPubkey)
    end
  end

  describe '#to_bytes' do
    it 'serializes the script back to original bytes' do
      script = described_class.from_raw(p2pkh_script_raw)
      expect(script.to_bytes).to eq(p2pkh_script_raw)
    end

    it 'works with P2PK script' do
      script = described_class.from_raw(genesis_p2pk_script_raw)
      expect(script.to_bytes).to eq(genesis_p2pk_script_raw)
    end
  end

  describe '#verify' do
    # Block 170: First Bitcoin transaction from Satoshi to Hal Finney
    # txid: f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16
    # This transaction spends the coinbase output from block 9
    context 'with Hal Finney transaction (block 170)' do
      # The spending transaction (block 170)
      let(:hal_finney_tx_hex) do
        "0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423edce25857fcd3704000000004847304402204e45e16932b8af514961a1d3a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07de4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac00286bee0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000"
      end
      let(:hal_finney_tx_raw) { [hal_finney_tx_hex].pack('H*') }

      # Block 9 coinbase output scriptPubkey (P2PK)
      # This is the output being spent by the Hal Finney transaction
      let(:block9_coinbase_script_hex) do
        "410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac"
      end
      let(:block9_coinbase_script_raw) { [block9_coinbase_script_hex].pack('H*') }

      # 50 BTC in satoshis
      let(:amount) { 50_0000_0000 }

      it 'returns true for valid P2PK script verification' do
        script = described_class.from_raw(block9_coinbase_script_raw)
        tx = BitcoinKernel::Transaction.from_raw(hal_finney_tx_raw)

        result = script.verify(
          amount: amount,
          tx: tx,
          input_index: 0,
          flags: BitcoinKernel::ScriptFlags::NONE
        )
        expect(result).to be true
      end

      it 'returns true with P2SH flag' do
        script = described_class.from_raw(block9_coinbase_script_raw)
        tx = BitcoinKernel::Transaction.from_raw(hal_finney_tx_raw)

        result = script.verify(
          amount: amount,
          tx: tx,
          input_index: 0,
          flags: BitcoinKernel::ScriptFlags::P2SH
        )
        expect(result).to be true
      end
    end

    context 'with invalid script' do
      let(:spending_tx_hex) do
        "0100000001" +
        "0000000000000000000000000000000000000000000000000000000000000000" +
        "00000000" +
        "00" +
        "ffffffff" +
        "01" +
        "0000000000000000" +
        "00" +
        "00000000"
      end
      let(:spending_tx_raw) { [spending_tx_hex].pack('H*') }

      it 'returns false for invalid script verification' do
        script = described_class.from_raw(p2pkh_script_raw)
        tx = BitcoinKernel::Transaction.from_raw(spending_tx_raw)

        result = script.verify(
          amount: 0,
          tx: tx,
          input_index: 0,
          flags: BitcoinKernel::ScriptFlags::NONE
        )
        expect(result).to be false
      end
    end
  end

  describe '#==' do
    it 'returns true for equal scripts' do
      script1 = described_class.from_raw(p2pkh_script_raw)
      script2 = described_class.from_raw(p2pkh_script_raw)
      expect(script1 == script2).to be(true)
    end

    it 'returns false for different scripts' do
      script1 = described_class.from_raw(p2pkh_script_raw)
      script2 = described_class.from_raw(genesis_p2pk_script_raw)
      expect(script1 == script2).to be(false)
    end

    it 'returns false for non-ScriptPubkey' do
      script = described_class.from_raw(p2pkh_script_raw)
      expect(script == "not a script").to be(false)
    end
  end

  describe 'ownership' do
    it 'can be created with owned: true (default)' do
      script = described_class.from_raw(p2pkh_script_raw)
      expect(script.autorelease?).to be true
    end

    it 'script from TransactionOutput has owned: false' do
      genesis_coinbase_hex =
        "01000000" +
        "01" +
        "0000000000000000000000000000000000000000000000000000000000000000" +
        "ffffffff" +
        "4d" +
        "04ffff001d0104455468652054696d65732030332f4a616e2f323030392043" +
        "68616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261" +
        "696c6f757420666f722062616e6b73" +
        "ffffffff" +
        "01" +
        "00f2052a01000000" +
        "43" +
        "4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f" +
        "61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b" +
        "6bf11d5fac" +
        "00000000"
      tx = BitcoinKernel::Transaction.from_raw([genesis_coinbase_hex].pack('H*'))
      output = tx.output_at(0)
      script = output.script_pubkey

      expect(script.autorelease?).to be false
    end
  end
end