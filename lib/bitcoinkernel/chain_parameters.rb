# frozen_string_literal: true

module BitcoinKernel
  # Represents chain parameters for a specific network.
  class ChainParameters < FFI::AutoPointer
    # Create chain parameters for the specified network.
    # @param [Integer] chain_type One of ChainType constants (MAINNET, TESTNET, etc.)
    # @return [ChainParameters]
    def self.create(chain_type = ChainType::MAINNET)
      ptr = BitcoinKernel.btck_chain_parameters_create(chain_type)
      raise Error, "Failed to create chain parameters" if ptr.null?
      new(ptr)
    end

    # Create chain parameters for mainnet.
    # @return [ChainParameters]
    def self.mainnet
      create(ChainType::MAINNET)
    end

    # Create chain parameters for testnet.
    # @return [ChainParameters]
    def self.testnet
      create(ChainType::TESTNET)
    end

    # Create chain parameters for testnet4.
    # @return [ChainParameters]
    def self.testnet4
      create(ChainType::TESTNET_4)
    end

    # Create chain parameters for signet.
    # @return [ChainParameters]
    def self.signet
      create(ChainType::SIGNET)
    end

    # Create chain parameters for regtest.
    # @return [ChainParameters]
    def self.regtest
      create(ChainType::REGTEST)
    end

    def self.release(ptr)
      BitcoinKernel.btck_chain_parameters_destroy(ptr)
    end
  end
end