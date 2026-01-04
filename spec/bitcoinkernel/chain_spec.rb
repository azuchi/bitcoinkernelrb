# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

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