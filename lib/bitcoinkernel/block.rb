# frozen_string_literal: true

module BitcoinKernel
  # Represents a Bitcoin block.
  class Block < FFI::AutoPointer
    include Serializable
    serialize_with :btck_block_to_bytes

    # Create a Block from raw serialized data.
    # @param [String] raw_block Serialized block data (binary string)
    # @return [Block]
    def self.from_raw(raw_block)
      raw_ptr = FFI::MemoryPointer.new(:uint8, raw_block.bytesize)
      raw_ptr.put_bytes(0, raw_block)
      ptr = BitcoinKernel.btck_block_create(raw_ptr, raw_block.bytesize)
      raise Error, "Failed to create block from raw data" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_block_destroy(ptr)
    end

    # Create a copy of this block.
    # @return [Block] A new Block instance with copied data
    def copy
      copied_ptr = BitcoinKernel.btck_block_copy(self)
      raise Error, "Failed to copy block" if copied_ptr.null?
      Block.new(copied_ptr)
    end

    # Compare two blocks for equality by their block hash.
    # @param [Block] other The other block to compare
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Block)
      block_hash == other.block_hash
    end

    # Number of transactions in the block.
    # @return [Integer]
    def transaction_count
      BitcoinKernel.btck_block_count_transactions(self)
    end

    # Get transaction at specified index.
    # @param [Integer] index Transaction index
    # @return [Transaction]
    def transaction_at(index)
      tx_ptr = BitcoinKernel.btck_block_get_transaction_at(self, index)
      raise Error, "Transaction not found at index #{index}" if tx_ptr.null?
      # Copy the transaction since the returned pointer is not owned
      copied_ptr = BitcoinKernel.btck_transaction_copy(tx_ptr)
      Transaction.new(copied_ptr)
    end

    # Get all transactions in the block.
    # @return [Array<Transaction>]
    def transactions
      transaction_count.times.map { |i| transaction_at(i) }
    end

    # Get the block hash.
    # @return [BlockHash]
    def block_hash
      hash_ptr = BitcoinKernel.btck_block_get_hash(self)
      raise Error, "Failed to get block hash" if hash_ptr.null?
      BlockHash.new(hash_ptr)
    end
  end
end