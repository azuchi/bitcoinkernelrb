# frozen_string_literal: true

module BitcoinKernel
  # Represents a transaction output.
  class TransactionOutput < FFI::AutoPointer
    # @param [FFI::Pointer] ptr Pointer to btck_TransactionOutput
    # @param [Boolean] owned Whether this object owns the pointer.
    #   When obtained via Transaction#output_at, the pointer is NOT owned
    #   and depends on the lifetime of the parent Transaction.
    #   In that case, owned should be false to prevent double-free.
    #   If you need to keep the TransactionOutput longer than the Transaction,
    #   use btck_transaction_output_copy to create an owned copy.
    def initialize(ptr, owned: true)
      super(ptr)
      self.autorelease = owned
    end

    def self.release(ptr)
      BitcoinKernel.btck_transaction_output_destroy(ptr)
    end

    # Get the output amount in satoshis.
    # @return [Integer]
    def amount
      BitcoinKernel.btck_transaction_output_get_amount(self)
    end

    # Get the script pubkey.
    # @return [ScriptPubkey]
    def script_pubkey
      spk_ptr = BitcoinKernel.btck_transaction_output_get_script_pubkey(self)
      raise Error, "Failed to get script pubkey" if spk_ptr.null?
      ScriptPubkey.new(spk_ptr, owned: false)
    end
  end
end