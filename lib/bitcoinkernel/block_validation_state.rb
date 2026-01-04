# frozen_string_literal: true

module BitcoinKernel
  # Represents the validation state of a block.
  #
  # Note: This class does not inherit from FFI::AutoPointer because:
  # - There is no btck_block_validation_state_destroy function in the library
  # - The pointer is not owned; it is passed to ValidationInterface callbacks
  # - The lifetime is only valid during the callback execution
  #
  # This object is obtained through the ValidationInterface#block_checked callback.
  class BlockValidationState
    # @param [FFI::Pointer] ptr Pointer to btck_BlockValidationState
    def initialize(ptr)
      @ptr = ptr
    end

    # Get the validation mode.
    # @return [Integer] One of ValidationMode constants (VALID, INVALID, INTERNAL_ERROR)
    def validation_mode
      BitcoinKernel.btck_block_validation_state_get_validation_mode(@ptr)
    end

    # Check if the block is valid.
    # @return [Boolean]
    def valid?
      validation_mode == ValidationMode::VALID
    end

    # Check if the block is invalid.
    # @return [Boolean]
    def invalid?
      validation_mode == ValidationMode::INVALID
    end

    # Check if there was an internal error during validation.
    # @return [Boolean]
    def internal_error?
      validation_mode == ValidationMode::INTERNAL_ERROR
    end

    # Get the block validation result (reason for invalidity).
    # @return [Integer] One of BlockValidationResult constants
    def block_validation_result
      BitcoinKernel.btck_block_validation_state_get_block_validation_result(@ptr)
    end

    # Get the underlying pointer for FFI calls.
    # @return [FFI::Pointer]
    def to_ptr
      @ptr
    end
  end
end