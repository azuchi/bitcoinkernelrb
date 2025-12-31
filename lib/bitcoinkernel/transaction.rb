# frozen_string_literal: true

module BitcoinKernel
  # Represents a Bitcoin transaction.
  class Transaction < FFI::AutoPointer
    include Serializable
    serialize_with :btck_transaction_to_bytes

    # Create a Transaction from raw serialized data.
    # @param [String] raw_tx Serialized transaction data (binary string)
    # @return [Transaction]
    def self.from_raw(raw_tx)
      raw_ptr = FFI::MemoryPointer.new(:uint8, raw_tx.bytesize)
      raw_ptr.put_bytes(0, raw_tx)
      ptr = BitcoinKernel.btck_transaction_create(raw_ptr, raw_tx.bytesize)
      raise Error, "Failed to create transaction from raw data" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_transaction_destroy(ptr)
    end

    # Number of inputs in the transaction.
    # @return [Integer]
    def input_count
      BitcoinKernel.btck_transaction_count_inputs(self)
    end

    # Number of outputs in the transaction.
    # @return [Integer]
    def output_count
      BitcoinKernel.btck_transaction_count_outputs(self)
    end

    # Get output at specified index.
    # @param [Integer] index Output index
    # @return [TransactionOutput]
    def output_at(index)
      out_ptr = BitcoinKernel.btck_transaction_get_output_at(self, index)
      raise Error, "Output not found at index #{index}" if out_ptr.null?
      TransactionOutput.new(out_ptr, owned: false)
    end

    # Get all outputs.
    # @return [Array<TransactionOutput>]
    def outputs
      output_count.times.map { |i| output_at(i) }
    end

    # Get input at specified index.
    # @param [Integer] index Input index
    # @return [TransactionInput]
    def input_at(index)
      in_ptr = BitcoinKernel.btck_transaction_get_input_at(self, index)
      raise Error, "Input not found at index #{index}" if in_ptr.null?
      TransactionInput.new(in_ptr, owned: false)
    end

    # Get all inputs.
    # @return [Array<TransactionInput>]
    def inputs
      input_count.times.map { |i| input_at(i) }
    end

    # Get the txid.
    # @return [Txid]
    def txid
      ptr = BitcoinKernel.btck_transaction_get_txid(self)
      raise Error, "Failed to get txid" if ptr.null?
      Txid.new(ptr, owned: false)
    end
  end
end