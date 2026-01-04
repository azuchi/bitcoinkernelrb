# frozen_string_literal: true

module BitcoinKernel
  # Base class for receiving validation interface callbacks.
  # Subclass this and override the methods you need.
  #
  # @example
  #   class MyValidationInterface < BitcoinKernel::ValidationInterface
  #     def block_checked(block, state)
  #       if state.valid?
  #         puts "Block valid: #{block.block_hash.to_hex}"
  #       end
  #     end
  #
  #     def block_connected(block, entry)
  #       puts "Block connected at height #{entry.height}"
  #     end
  #   end
  #
  #   vi = MyValidationInterface.new
  #   options = BitcoinKernel::ContextOptions.create
  #   options.set_validation_interface(vi)
  class ValidationInterface
    def initialize
      # Store procs to prevent garbage collection
      @stored_procs = []
    end

    # Called when a block has been fully validated.
    # @param [Block] block The validated block
    # @param [BlockValidationState] state The validation state
    def block_checked(block, state)
      # Override in subclass
    end

    # Called when a block extends the header chain with valid PoW.
    # @param [Block] block The block
    # @param [BlockTreeEntry] entry The block tree entry
    def pow_valid_block(block, entry)
      # Override in subclass
    end

    # Called when a block is connected to the best chain.
    # @param [Block] block The connected block
    # @param [BlockTreeEntry] entry The block tree entry
    def block_connected(block, entry)
      # Override in subclass
    end

    # Called when a block is disconnected during a reorg.
    # @param [Block] block The disconnected block
    # @param [BlockTreeEntry] entry The block tree entry
    def block_disconnected(block, entry)
      # Override in subclass
    end

    # Build the FFI callbacks struct.
    # @return [ValidationInterfaceCallbacks]
    # @api private
    def to_ffi_callbacks
      callbacks = ValidationInterfaceCallbacks.new

      callbacks[:user_data] = FFI::Pointer::NULL
      callbacks[:user_data_destroy] = nil

      block_checked_proc = create_block_checked_proc
      @stored_procs << block_checked_proc
      callbacks[:block_checked] = block_checked_proc

      pow_valid_block_proc = create_block_entry_proc(:pow_valid_block)
      @stored_procs << pow_valid_block_proc
      callbacks[:pow_valid_block] = pow_valid_block_proc

      block_connected_proc = create_block_entry_proc(:block_connected)
      @stored_procs << block_connected_proc
      callbacks[:block_connected] = block_connected_proc

      block_disconnected_proc = create_block_entry_proc(:block_disconnected)
      @stored_procs << block_disconnected_proc
      callbacks[:block_disconnected] = block_disconnected_proc

      callbacks
    end

    private

    def create_block_checked_proc
      proc do |_user_data, block_ptr, state_ptr|
        # Copy the block since the pointer may not be owned
        copied_ptr = BitcoinKernel.btck_block_copy(block_ptr)
        block = Block.new(copied_ptr)
        state = BlockValidationState.new(state_ptr)
        block_checked(block, state)
      end
    end

    def create_block_entry_proc(method_name)
      proc do |_user_data, block_ptr, entry_ptr|
        # Copy the block since the pointer may not be owned
        copied_ptr = BitcoinKernel.btck_block_copy(block_ptr)
        block = Block.new(copied_ptr)
        entry = BlockTreeEntry.new(entry_ptr, owned: false)
        send(method_name, block, entry)
      end
    end
  end
end