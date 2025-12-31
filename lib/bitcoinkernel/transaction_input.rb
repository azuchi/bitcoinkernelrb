# frozen_string_literal: true

module BitcoinKernel
  # Represents a transaction input.
  class TransactionInput < FFI::AutoPointer
    # @param [FFI::Pointer] ptr Pointer to btck_TransactionInput
    # @param [Boolean] owned Whether this object owns the pointer.
    #   When obtained via Transaction#input_at, the pointer is NOT owned
    #   and depends on the lifetime of the parent Transaction.
    #   In that case, owned should be false to prevent double-free.
    def initialize(ptr, owned: true)
      super(ptr)
      self.autorelease = owned
    end

    def self.release(ptr)
      BitcoinKernel.btck_transaction_input_destroy(ptr)
    end

    # Get the outpoint (previous transaction output being spent).
    # @return [TransactionOutPoint]
    def out_point
      out_point_ptr = BitcoinKernel.btck_transaction_input_get_out_point(self)
      raise Error, "Failed to get out point" if out_point_ptr.null?
      TransactionOutPoint.new(out_point_ptr, owned: false)
    end
  end
end