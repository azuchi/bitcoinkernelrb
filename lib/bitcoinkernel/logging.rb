# frozen_string_literal: true

module BitcoinKernel
  # Logging configuration for Bitcoin Kernel.
  module Logging
    # Logging options struct for FFI
    class Options < FFI::Struct
      layout :log_timestamps, :int,
             :log_time_micros, :int,
             :log_threadnames, :int,
             :log_sourcelocations, :int,
             :always_print_category_levels, :int
    end

    # Log categories
    module Category
      ALL = 0
      BENCH = 1
      BLOCKSTORAGE = 2
      COINDB = 3
      LEVELDB = 4
      MEMPOOL = 5
      PRUNE = 6
      RAND = 7
      REINDEX = 8
      VALIDATION = 9
      KERNEL = 10
    end

    # Log levels
    module Level
      TRACE = 0
      DEBUG = 1
      INFO = 2
    end

    # Permanently disable kernel logging output for this process.
    # Once called, logging cannot be re-enabled.
    # This function should only be called once and is not thread-safe.
    def self.disable
      BitcoinKernel.btck_logging_disable
    end

    # Set logging format options.
    # @param [Hash] opts Logging options
    # @option opts [Boolean] :timestamps Prepend timestamp to log messages
    # @option opts [Boolean] :time_micros Log timestamps in microsecond precision
    # @option opts [Boolean] :threadnames Prepend thread name to log messages
    # @option opts [Boolean] :sourcelocations Prepend source location to log messages
    # @option opts [Boolean] :category_levels Prepend log category and level to log messages
    def self.set_options(timestamps: false, time_micros: false, threadnames: false,
                         sourcelocations: false, category_levels: false)
      opts = Options.new
      opts[:log_timestamps] = timestamps ? 1 : 0
      opts[:log_time_micros] = time_micros ? 1 : 0
      opts[:log_threadnames] = threadnames ? 1 : 0
      opts[:log_sourcelocations] = sourcelocations ? 1 : 0
      opts[:always_print_category_levels] = category_levels ? 1 : 0
      BitcoinKernel.btck_logging_set_options(opts)
    end

    # Set log level for a specific category.
    # @param [Integer] category One of Category constants
    # @param [Integer] level One of Level constants
    def self.set_level(category, level)
      BitcoinKernel.btck_logging_set_level_category(category, level)
    end

    # Enable a log category.
    # @param [Integer] category One of Category constants (use Category::ALL to enable all)
    def self.enable_category(category)
      BitcoinKernel.btck_logging_enable_category(category)
    end

    # Disable a log category.
    # @param [Integer] category One of Category constants (use Category::ALL to disable all)
    def self.disable_category(category)
      BitcoinKernel.btck_logging_disable_category(category)
    end
  end
end