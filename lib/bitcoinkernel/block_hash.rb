# frozen_string_literal: true

module BitcoinKernel
  # Represents a block hash.
  class BlockHash < FFI::AutoPointer
    # Create a BlockHash from raw bytes.
    # @param [String] bytes 32-byte hash (binary string)
    # @return [BlockHash]
    def self.from_bytes(bytes)
      raise Error, "Block hash must be 32 bytes" unless bytes.bytesize == 32
      raw_ptr = FFI::MemoryPointer.new(:uint8, 32)
      raw_ptr.put_bytes(0, bytes)
      ptr = BitcoinKernel.btck_block_hash_create(raw_ptr)
      raise Error, "Failed to create block hash" if ptr.null?
      new(ptr)
    end

    # Create a BlockHash from hex string.
    # @param [String] hex 64-character hex string (little-endian, as commonly displayed)
    # @return [BlockHash]
    def self.from_hex(hex)
      bytes = [hex].pack('H*').reverse
      from_bytes(bytes)
    end

    def self.release(ptr)
      BitcoinKernel.btck_block_hash_destroy(ptr)
    end

    # Get the hash as raw bytes.
    # @return [String] 32-byte binary string
    def to_bytes
      output = FFI::MemoryPointer.new(:uint8, 32)
      BitcoinKernel.btck_block_hash_to_bytes(self, output)
      output.read_bytes(32)
    end

    # Get the hash as hex string (little-endian, as commonly displayed).
    # @return [String]
    def to_hex
      to_bytes.reverse.unpack1('H*')
    end

    # Compare two block hashes for equality.
    # @param [BlockHash] other The other block hash to compare
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(BlockHash)
      BitcoinKernel.btck_block_hash_equals(self, other) == 1
    end
  end
end