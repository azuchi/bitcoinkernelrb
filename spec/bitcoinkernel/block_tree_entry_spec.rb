# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

RSpec.describe BitcoinKernel::BlockTreeEntry do
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

  let(:genesis_entry) do
    chainstate_manager.active_chain.entry_at(0)
  end

  describe '#height' do
    it 'returns the block height' do
      expect(genesis_entry.height).to eq(0)
    end
  end

  describe '#block_hash' do
    it 'returns the block hash' do
      expect(genesis_entry.block_hash).to be_a(BitcoinKernel::BlockHash)
    end
  end

  describe '#previous' do
    it 'returns nil for genesis block' do
      expect(genesis_entry.previous).to be_nil
    end
  end

  describe '#==' do
    it 'returns true for same entry' do
      entry1 = chainstate_manager.active_chain.entry_at(0)
      entry2 = chainstate_manager.active_chain.entry_at(0)
      expect(entry1 == entry2).to be(true)
    end

    it 'returns false for non-BlockTreeEntry' do
      expect(genesis_entry == "not an entry").to be(false)
    end
  end
end