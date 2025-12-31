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
  end
end