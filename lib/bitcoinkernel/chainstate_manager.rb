# frozen_string_literal: true

module BitcoinKernel
  # Manages chainstate and block validation.
  class ChainstateManager < FFI::AutoPointer
    # Create a chainstate manager.
    # @param [ChainstateManagerOptions] options Options for the chainstate manager
    # @return [ChainstateManager]
    def self.create(options)
      ptr = BitcoinKernel.btck_chainstate_manager_create(options)
      raise Error, "Failed to create chainstate manager" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_chainstate_manager_destroy(ptr)
    end

    # Process and validate a block.
    # @param [Block] block The block to process
    # @return [Boolean] true if processing was successful (not indicative of validity)
    def process_block(block)
      new_block_ptr = FFI::MemoryPointer.new(:int)
      result = BitcoinKernel.btck_chainstate_manager_process_block(self, block, new_block_ptr)
      result == 0
    end

    # Get the currently active chain.
    # @return [Chain]
    def active_chain
      ptr = BitcoinKernel.btck_chainstate_manager_get_active_chain(self)
      raise Error, "Failed to get active chain" if ptr.null?
      Chain.new(ptr, owned: false)
    end

    # Get a block tree entry by its hash.
    # @param [BlockHash] block_hash The block hash to look up
    # @return [BlockTreeEntry, nil] The block tree entry, or nil if not found
    def block_tree_entry_by_hash(block_hash)
      ptr = BitcoinKernel.btck_chainstate_manager_get_block_tree_entry_by_hash(self, block_hash)
      return nil if ptr.null?
      BlockTreeEntry.new(ptr, owned: false)
    end

    # Read a block from disk by its block tree entry.
    # @param [BlockTreeEntry] entry The block tree entry
    # @return [Block]
    def read_block(entry)
      ptr = BitcoinKernel.btck_block_read(self, entry)
      raise Error, "Failed to read block" if ptr.null?
      Block.new(ptr)
    end
  end
end