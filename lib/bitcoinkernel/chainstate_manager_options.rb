# frozen_string_literal: true

module BitcoinKernel
  # Options for creating a ChainstateManager.
  class ChainstateManagerOptions < FFI::AutoPointer
    # Create chainstate manager options.
    # @param [Context] context The kernel context
    # @param [String] data_directory Path to the chainstate data directory
    # @param [String] blocks_directory Path to the blocks directory
    # @return [ChainstateManagerOptions]
    def self.create(context:, data_directory:, blocks_directory:)
      ptr = BitcoinKernel.btck_chainstate_manager_options_create(
        context,
        data_directory, data_directory.bytesize,
        blocks_directory, blocks_directory.bytesize
      )
      raise Error, "Failed to create chainstate manager options" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_chainstate_manager_options_destroy(ptr)
    end

    # Set the number of worker threads for validation.
    # @param [Integer] num Number of worker threads (0-15)
    # @return [self]
    def set_worker_threads(num)
      BitcoinKernel.btck_chainstate_manager_options_set_worker_threads_num(self, num)
      self
    end

    # Set wipe database options for reindexing.
    # @param [Boolean] wipe_block_tree_db Wipe block tree db (should only be true if wipe_chainstate_db is also true)
    # @param [Boolean] wipe_chainstate_db Wipe chainstate db
    # @return [Boolean] true if successful
    def set_wipe_dbs(wipe_block_tree_db:, wipe_chainstate_db:)
      result = BitcoinKernel.btck_chainstate_manager_options_set_wipe_dbs(
        self,
        wipe_block_tree_db ? 1 : 0,
        wipe_chainstate_db ? 1 : 0
      )
      result == 0
    end

    # Set block tree db to be in memory.
    # @param [Boolean] in_memory Whether to use in-memory database
    # @return [self]
    def set_block_tree_db_in_memory(in_memory = true)
      BitcoinKernel.btck_chainstate_manager_options_update_block_tree_db_in_memory(self, in_memory ? 1 : 0)
      self
    end

    # Set chainstate db to be in memory.
    # @param [Boolean] in_memory Whether to use in-memory database
    # @return [self]
    def set_chainstate_db_in_memory(in_memory = true)
      BitcoinKernel.btck_chainstate_manager_options_update_chainstate_db_in_memory(self, in_memory ? 1 : 0)
      self
    end
  end
end