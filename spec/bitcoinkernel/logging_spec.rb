# frozen_string_literal: true

RSpec.describe BitcoinKernel::Logging do
  describe '.disable' do
    it 'disables logging without error' do
      expect { described_class.disable }.not_to raise_error
    end
  end

  describe '.set_options' do
    it 'sets logging options without error' do
      expect {
        described_class.set_options(
          timestamps: true,
          time_micros: true,
          threadnames: true,
          sourcelocations: true,
          category_levels: true
        )
      }.not_to raise_error
    end
  end

  describe '.set_level' do
    it 'sets log level for a category without error' do
      expect {
        described_class.set_level(
          BitcoinKernel::Logging::Category::VALIDATION,
          BitcoinKernel::Logging::Level::DEBUG
        )
      }.not_to raise_error
    end

    it 'sets log level for all categories without error' do
      expect {
        described_class.set_level(
          BitcoinKernel::Logging::Category::ALL,
          BitcoinKernel::Logging::Level::INFO
        )
      }.not_to raise_error
    end
  end

  describe '.enable_category' do
    it 'enables a log category without error' do
      expect {
        described_class.enable_category(BitcoinKernel::Logging::Category::VALIDATION)
      }.not_to raise_error
    end
  end

  describe '.disable_category' do
    it 'disables a log category without error' do
      expect {
        described_class.disable_category(BitcoinKernel::Logging::Category::VALIDATION)
      }.not_to raise_error
    end
  end

  describe 'Category' do
    it 'has all category constants' do
      expect(BitcoinKernel::Logging::Category::ALL).to eq(0)
      expect(BitcoinKernel::Logging::Category::BENCH).to eq(1)
      expect(BitcoinKernel::Logging::Category::BLOCKSTORAGE).to eq(2)
      expect(BitcoinKernel::Logging::Category::COINDB).to eq(3)
      expect(BitcoinKernel::Logging::Category::LEVELDB).to eq(4)
      expect(BitcoinKernel::Logging::Category::MEMPOOL).to eq(5)
      expect(BitcoinKernel::Logging::Category::PRUNE).to eq(6)
      expect(BitcoinKernel::Logging::Category::RAND).to eq(7)
      expect(BitcoinKernel::Logging::Category::REINDEX).to eq(8)
      expect(BitcoinKernel::Logging::Category::VALIDATION).to eq(9)
      expect(BitcoinKernel::Logging::Category::KERNEL).to eq(10)
    end
  end

  describe 'Level' do
    it 'has all level constants' do
      expect(BitcoinKernel::Logging::Level::TRACE).to eq(0)
      expect(BitcoinKernel::Logging::Level::DEBUG).to eq(1)
      expect(BitcoinKernel::Logging::Level::INFO).to eq(2)
    end
  end
end