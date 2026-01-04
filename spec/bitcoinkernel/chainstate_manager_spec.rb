# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

RSpec.describe BitcoinKernel::ChainstateManagerOptions do
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

  describe '.create' do
    it 'creates chainstate manager options' do
      options = described_class.create(
        context: context,
        data_directory: @data_dir,
        blocks_directory: @blocks_dir
      )
      expect(options).to be_a(BitcoinKernel::ChainstateManagerOptions)
    end
  end

  describe '#set_worker_threads' do
    it 'sets worker threads and returns self' do
      options = described_class.create(
        context: context,
        data_directory: @data_dir,
        blocks_directory: @blocks_dir
      )
      result = options.set_worker_threads(4)
      expect(result).to eq(options)
    end
  end

  describe '#set_block_tree_db_in_memory' do
    it 'sets in-memory mode and returns self' do
      options = described_class.create(
        context: context,
        data_directory: @data_dir,
        blocks_directory: @blocks_dir
      )
      result = options.set_block_tree_db_in_memory(true)
      expect(result).to eq(options)
    end
  end

  describe '#set_chainstate_db_in_memory' do
    it 'sets in-memory mode and returns self' do
      options = described_class.create(
        context: context,
        data_directory: @data_dir,
        blocks_directory: @blocks_dir
      )
      result = options.set_chainstate_db_in_memory(true)
      expect(result).to eq(options)
    end
  end

  describe '#set_wipe_dbs' do
    it 'sets wipe database options' do
      options = described_class.create(
        context: context,
        data_directory: @data_dir,
        blocks_directory: @blocks_dir
      )
      result = options.set_wipe_dbs(wipe_block_tree_db: true, wipe_chainstate_db: true)
      expect(result).to eq(true)
    end
  end
end

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
      next unless chain.height >= 0

      entry = chain.entry_at(0)
      next if entry.nil?

      read_block = manager.read_block(entry)
      expect(read_block).to be_a(BitcoinKernel::Block)
      expect(read_block.block_hash.to_hex).to eq(block.block_hash.to_hex)
    end
  end
end

RSpec.describe BitcoinKernel::Chain do
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

  let(:chainstate_manager) do
    options = BitcoinKernel::ChainstateManagerOptions.create(
      context: context,
      data_directory: @data_dir,
      blocks_directory: @blocks_dir
    ).set_block_tree_db_in_memory
     .set_chainstate_db_in_memory
    BitcoinKernel::ChainstateManager.create(options)
  end

  describe '#height' do
    it 'returns the chain height' do
      chain = chainstate_manager.active_chain
      # Genesis block height is 0, but empty chain returns -1
      expect(chain.height).to be_a(Integer)
    end
  end

  describe '#entry_at' do
    it 'returns nil for out of bounds height' do
      chain = chainstate_manager.active_chain
      entry = chain.entry_at(1000000)
      expect(entry).to be_nil
    end

    it 'returns genesis entry at height 0' do
      chain = chainstate_manager.active_chain
      entry = chain.entry_at(0)
      expect(entry).to be_a(BitcoinKernel::BlockTreeEntry)
      expect(entry.height).to eq(0)
    end
  end

  describe '#contains?' do
    it 'returns true for entry in chain' do
      chain = chainstate_manager.active_chain
      entry = chain.entry_at(0)
      expect(chain.contains?(entry)).to be(true)
    end
  end
end