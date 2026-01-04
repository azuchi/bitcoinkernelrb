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