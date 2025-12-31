# frozen_string_literal: true

module BitcoinKernel
  # Represents the active blockchain.
  # This is a view into the chainstate manager's active chain.
  #
  # Note: This class does not inherit from FFI::AutoPointer because:
  # - There is no btck_chain_destroy function in the library
  # - The pointer is not owned; it points to internal data of ChainstateManager
  # - The lifetime depends on the parent ChainstateManager
  class Chain
    # @param [FFI::Pointer] ptr Pointer to btck_Chain
    # @param [Boolean] owned Whether this object owns the pointer.
    #   Chain pointers from ChainstateManager are NOT owned.
    def initialize(ptr, owned: false)
      @ptr = ptr
      @owned = owned
    end

    # Get the height of the chain tip.
    # @return [Integer]
    def height
      BitcoinKernel.btck_chain_get_height(@ptr)
    end

    # Get the block tree entry at the specified height.
    # @param [Integer] block_height The height to query
    # @return [BlockTreeEntry, nil] The block tree entry, or nil if height is out of bounds
    def entry_at(block_height)
      ptr = BitcoinKernel.btck_chain_get_by_height(@ptr, block_height)
      return nil if ptr.null?
      BlockTreeEntry.new(ptr, owned: false)
    end

    # Check if the chain contains a block tree entry.
    # @param [BlockTreeEntry] entry The entry to check
    # @return [Boolean]
    def contains?(entry)
      BitcoinKernel.btck_chain_contains(@ptr, entry.to_ptr) == 1
    end

    # Get the underlying pointer for FFI calls.
    # @return [FFI::Pointer]
    def to_ptr
      @ptr
    end
  end
end