# frozen_string_literal: true

module BitcoinKernel
  # Options for creating a Context.
  class ContextOptions < FFI::AutoPointer
    # Create new context options.
    # @return [ContextOptions]
    def self.create
      ptr = BitcoinKernel.btck_context_options_create
      raise Error, "Failed to create context options" if ptr.null?
      new(ptr)
    end

    def self.release(ptr)
      BitcoinKernel.btck_context_options_destroy(ptr)
    end

    # Set chain parameters for this context.
    # @param [ChainParameters] chain_params Chain parameters to use
    # @return [self]
    def set_chainparams(chain_params)
      BitcoinKernel.btck_context_options_set_chainparams(self, chain_params)
      self
    end
  end
end