# frozen_string_literal: true

module BitcoinKernel
  # Represents an entry in the block tree.
  #
  # Note: This class does not inherit from FFI::AutoPointer because:
  # - There is no btck_block_tree_entry_destroy function in the library
  # - The pointer is not owned; it points to internal data of ChainstateManager
  # - The lifetime depends on the parent ChainstateManager or Chain
  class BlockTreeEntry
    # @param [FFI::Pointer] ptr Pointer to btck_BlockTreeEntry
    # @param [Boolean] owned Whether this object owns the pointer.
    #   BlockTreeEntry pointers from Chain/ChainstateManager are NOT owned.
    def initialize(ptr, owned: false)
      @ptr = ptr
      @owned = owned
    end

    # Get the height of this block in the chain.
    # @return [Integer]
    def height
      BitcoinKernel.btck_block_tree_entry_get_height(@ptr)
    end

    # Get the block hash.
    # @return [BlockHash]
    def block_hash
      ptr = BitcoinKernel.btck_block_tree_entry_get_block_hash(@ptr)
      raise Error, "Failed to get block hash" if ptr.null?
      # The returned pointer is not owned, but we need to copy it for safety
      bytes = FFI::MemoryPointer.new(:uint8, 32)
      BitcoinKernel.btck_block_hash_to_bytes(ptr, bytes)
      BlockHash.from_bytes(bytes.read_bytes(32))
    end

    # Get the previous block tree entry.
    # @return [BlockTreeEntry, nil] The previous entry, or nil if this is the genesis block
    def previous
      ptr = BitcoinKernel.btck_block_tree_entry_get_previous(@ptr)
      return nil if ptr.null?
      BlockTreeEntry.new(ptr, owned: false)
    end

    # Compare two block tree entries for equality.
    # @param [BlockTreeEntry] other The other entry to compare
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(BlockTreeEntry)
      BitcoinKernel.btck_block_tree_entry_equals(@ptr, other.to_ptr) == 1
    end

    # Get the underlying pointer for FFI calls.
    # @return [FFI::Pointer]
    def to_ptr
      @ptr
    end
  end
end