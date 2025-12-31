# frozen_string_literal: true

module BitcoinKernel
  # Represents the kernel context.
  class Context < FFI::AutoPointer
    # Create a new context with the given options.
    # @param [ContextOptions, nil] options Context options (nil for defaults)
    # @return [Context]
    def self.create(options = nil)
      opts_ptr = options&.to_ptr
      ptr = BitcoinKernel.btck_context_create(opts_ptr)
      raise Error, "Failed to create context" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_context_destroy(ptr)
    end

    # Interrupt the context.
    # @return [Boolean] true if interrupt was successful
    def interrupt
      BitcoinKernel.btck_context_interrupt(self) == 0
    end
  end
end