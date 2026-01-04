# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

RSpec.describe BitcoinKernel::ChainstateManager do
  let(:context) do
    options = BitcoinKernel::ContextOptions.create
    params = BitcoinKernel::ChainParameters.regtest
    options.set_chainparams(params)
    BitcoinKernel::Context.create(options)
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @data_dir = File.join(dir, 'data')
      @blocks_dir = File.join(dir, 'blocks')
      FileUtils.mkdir_p(@data_dir)
      FileUtils.mkdir_p(@blocks_dir)
      example.run
    end
  end

  let(:chainstate_manager_options) do
    BitcoinKernel::ChainstateManagerOptions.create(
      context: context,
      data_directory: @data_dir,
      blocks_directory: @blocks_dir
    ).set_block_tree_db_in_memory
     .set_chainstate_db_in_memory
  end

  describe '.create' do
    it 'creates chainstate manager' do
      manager = described_class.create(chainstate_manager_options)
      expect(manager).to be_a(BitcoinKernel::ChainstateManager)
    end
  end

  describe '#active_chain' do
    it 'returns the active chain' do
      manager = described_class.create(chainstate_manager_options)
      chain = manager.active_chain
      expect(chain).to be_a(BitcoinKernel::Chain)
    end
  end

  describe '#process_block' do
    # Regtest genesis block
    let(:regtest_genesis_hex) do
      '0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4adae5494dffff7f20020000000101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a0100000043410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac00000000'
    end

    it 'returns false for genesis block (already in chain)' do
      manager = described_class.create(chainstate_manager_options)
      block = BitcoinKernel::Block.from_raw([regtest_genesis_hex].pack('H*'))
      # Genesis block is already part of the chain, so process_block returns false
      result = manager.process_block(block)
      expect(result).to be(false)
    end
  end

  describe '#block_tree_entry_by_hash' do
    it 'returns nil for unknown hash' do
      manager = described_class.create(chainstate_manager_options)
      unknown_hash = BitcoinKernel::BlockHash.from_hex('0000000000000000000000000000000000000000000000000000000000000001')
      entry = manager.block_tree_entry_by_hash(unknown_hash)
      expect(entry).to be_nil
    end
  end

  describe '#read_block' do
    # Regtest genesis block
    let(:regtest_genesis_hex) do
      '0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4adae5494dffff7f20020000000101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a0100000043410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac00000000'
    end

    it 'reads a block from disk after processing' do
      manager = described_class.create(chainstate_manager_options)
      block = BitcoinKernel::Block.from_raw([regtest_genesis_hex].pack('H*'))
      manager.process_block(block)

      # Get the genesis block entry from chain
      chain = manager.active_chain
      expect(chain.height).to be >= 0

      entry = chain.entry_at(0)
      expect(entry).not_to be_nil

      read_block = manager.read_block(entry)
      expect(read_block).to be_a(BitcoinKernel::Block)
      expect(read_block).to eq(block)
    end
  end
end