# frozen_string_literal: true

module BitcoinKernel
  # Represents a transaction outpoint (reference to a previous output).
  class TransactionOutPoint < FFI::AutoPointer
    # @param [FFI::Pointer] ptr Pointer to btck_TransactionOutPoint
    # @param [Boolean] owned Whether this object owns the pointer.
    #   When obtained via TransactionInput#out_point, the pointer is NOT owned
    #   and depends on the lifetime of the parent TransactionInput.
    #   In that case, owned should be false to prevent double-free.
    def initialize(ptr, owned: true)
      super(ptr)
      self.autorelease = owned
    end

    def self.release(ptr)
      BitcoinKernel.btck_transaction_out_point_destroy(ptr)
    end

    # Get the index of the output in the previous transaction.
    # @return [Integer]
    def index
      BitcoinKernel.btck_transaction_out_point_get_index(self)
    end

    # Get the txid of the previous transaction.
    # @return [Txid]
    def txid
      ptr = BitcoinKernel.btck_transaction_out_point_get_txid(self)
      raise Error, "Failed to get txid" if ptr.null?
      Txid.new(ptr, owned: false)
    end
  end
end