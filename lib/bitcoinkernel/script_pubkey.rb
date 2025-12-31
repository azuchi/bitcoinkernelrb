# frozen_string_literal: true

module BitcoinKernel
  # Represents a script pubkey.
  class ScriptPubkey < FFI::AutoPointer
    include Serializable
    serialize_with :btck_script_pubkey_to_bytes

    # Create a ScriptPubkey from raw bytes.
    # @param [String] script Raw script bytes (binary string)
    # @return [ScriptPubkey]
    def self.from_raw(script)
      raw_ptr = FFI::MemoryPointer.new(:uint8, script.bytesize)
      raw_ptr.put_bytes(0, script)
      ptr = BitcoinKernel.btck_script_pubkey_create(raw_ptr, script.bytesize)
      raise Error, "Failed to create script pubkey" if ptr.null?
      new(ptr)
    end

    # @param [FFI::Pointer] ptr Pointer to btck_ScriptPubkey
    # @param [Boolean] owned Whether this object owns the pointer.
    #   When obtained via TransactionOutput#script_pubkey, the pointer is NOT owned
    #   and depends on the lifetime of the parent TransactionOutput.
    #   In that case, owned should be false to prevent double-free.
    def initialize(ptr, owned: true)
      super(ptr)
      self.autorelease = owned
    end

    def self.release(ptr)
      BitcoinKernel.btck_script_pubkey_destroy(ptr)
    end

    # Verify that the script is correctly spent by a transaction input.
    # @param [Integer] amount Amount in satoshis
    # @param [Transaction] tx Transaction spending this script
    # @param [Integer] input_index Index of the input spending this script
    # @param [Array<TransactionOutput>] spent_outputs All spent outputs (required for taproot)
    # @param [Integer] flags Script verification flags (default: ScriptFlags::ALL)
    # @return [Boolean] true if verification succeeded
    def verify(amount:, tx:, input_index:, spent_outputs: [], flags: ScriptFlags::ALL)
      status_ptr = FFI::MemoryPointer.new(:uint8)

      if spent_outputs.empty?
        result = BitcoinKernel.btck_script_pubkey_verify(
          self, amount, tx, nil, 0, input_index, flags, status_ptr
        )
      else
        outputs_ptr = FFI::MemoryPointer.new(:pointer, spent_outputs.size)
        spent_outputs.each_with_index do |out, i|
          outputs_ptr.put_pointer(i * FFI::Pointer.size, out)
        end
        result = BitcoinKernel.btck_script_pubkey_verify(
          self, amount, tx, outputs_ptr, spent_outputs.size, input_index, flags, status_ptr
        )
      end

      result == 1
    end
  end
end