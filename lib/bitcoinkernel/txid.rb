# frozen_string_literal: true

module BitcoinKernel
  # Represents a transaction ID (txid).
  class Txid < FFI::AutoPointer
    # @param [FFI::Pointer] ptr Pointer to btck_Txid
    # @param [Boolean] owned Whether this object owns the pointer.
    #   When obtained via Transaction#txid_ptr, the pointer is NOT owned
    #   and depends on the lifetime of the parent Transaction.
    #   In that case, owned should be false to prevent double-free.
    def initialize(ptr, owned: true)
      super(ptr)
      self.autorelease = owned
    end

    def self.release(ptr)
      BitcoinKernel.btck_txid_destroy(ptr)
    end

    # Get the txid as raw bytes.
    # @return [String] 32-byte binary string
    def to_bytes
      output = FFI::MemoryPointer.new(:uint8, 32)
      BitcoinKernel.btck_txid_to_bytes(self, output)
      output.read_bytes(32)
    end

    # Get the txid as hex string (little-endian, as commonly displayed).
    # @return [String]
    def to_hex
      to_bytes.reverse.unpack1('H*')
    end

    # Compare two txids for equality.
    # @param [Txid] other The other txid to compare
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Txid)
      BitcoinKernel.btck_txid_equals(self, other) == 1
    end
  end
end