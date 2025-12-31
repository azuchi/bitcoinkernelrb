# frozen_string_literal: true

module BitcoinKernel
  # Mixin for classes that can be serialized to bytes.
  # Include this module and call `serialize_with` to define the to_bytes method.
  #
  # @example
  #   class Block < FFI::AutoPointer
  #     include Serializable
  #     serialize_with :btck_block_to_bytes
  #   end
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Define a to_bytes method using the specified FFI serialization function.
      # @param ffi_method [Symbol] The FFI function name for serialization
      def serialize_with(ffi_method)
        define_method(:to_bytes) do
          buffer = []
          callback = proc do |bytes_ptr, size, _userdata|
            buffer << bytes_ptr.read_bytes(size)
            0
          end
          BitcoinKernel.send(ffi_method, self, callback, nil)
          buffer.join.b
        end
      end
    end
  end
end