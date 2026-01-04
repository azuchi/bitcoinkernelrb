# frozen_string_literal: true

RSpec.describe BitcoinKernel::ValidationInterface do
  describe '#to_ffi_callbacks' do
    it 'returns callbacks struct with all callbacks set' do
      vi = described_class.new
      callbacks = vi.to_ffi_callbacks

      expect(callbacks[:block_checked]).not_to be_nil
      expect(callbacks[:pow_valid_block]).not_to be_nil
      expect(callbacks[:block_connected]).not_to be_nil
      expect(callbacks[:block_disconnected]).not_to be_nil
    end
  end

  describe 'subclassing' do
    let(:test_class) do
      Class.new(described_class) do
        attr_reader :checked_blocks

        def initialize
          super
          @checked_blocks = []
        end

        def block_checked(block, state)
          @checked_blocks << { block: block, state: state }
        end
      end
    end

    it 'allows overriding callback methods' do
      vi = test_class.new
      expect(vi).to respond_to(:block_checked)
      expect(vi.checked_blocks).to eq([])
    end
  end

  describe 'integration with ContextOptions' do
    it 'can be set on context options' do
      vi = described_class.new

      options = BitcoinKernel::ContextOptions.create
      params = BitcoinKernel::ChainParameters.regtest
      options.set_chainparams(params)
      result = options.set_validation_interface(vi)

      expect(result).to eq(options)
    end
  end
end