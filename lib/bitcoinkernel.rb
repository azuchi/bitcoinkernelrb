# frozen_string_literal: true

require_relative "bitcoinkernel/version"
require 'ffi'

# Bitcoin Kernel bindings.
module BitcoinKernel
  class Error < StandardError; end

  extend FFI::Library
  ffi_lib(ENV['LIB_BITCOINKERNEL_PATH'])

  # Chain types
  module ChainType
    MAINNET = 0
    TESTNET = 1
    TESTNET_4 = 2
    SIGNET = 3
    REGTEST = 4
  end

  # Validation modes
  module ValidationMode
    VALID = 0
    INVALID = 1
    INTERNAL_ERROR = 2
  end

  # Block validation results
  module BlockValidationResult
    UNSET = 0
    CONSENSUS = 1
    CACHED_INVALID = 2
    INVALID_HEADER = 3
    MUTATED = 4
    MISSING_PREV = 5
    INVALID_PREV = 6
    TIME_FUTURE = 7
    HEADER_LOW_WORK = 8
  end

  # Script verification flags
  module ScriptFlags
    NONE = 0
    P2SH = (1 << 0)
    DERSIG = (1 << 2)
    NULLDUMMY = (1 << 4)
    CHECKLOCKTIMEVERIFY = (1 << 9)
    CHECKSEQUENCEVERIFY = (1 << 10)
    WITNESS = (1 << 11)
    TAPROOT = (1 << 17)
    ALL = P2SH | DERSIG | NULLDUMMY | CHECKLOCKTIMEVERIFY | CHECKSEQUENCEVERIFY | WITNESS | TAPROOT
  end


  # Logging
  attach_function :btck_logging_disable, [], :void

  # Chain parameters
  attach_function :btck_chain_parameters_create, [:uint8], :pointer
  attach_function :btck_chain_parameters_destroy, [:pointer], :void

  # Context options
  attach_function :btck_context_options_create, [], :pointer
  attach_function :btck_context_options_set_chainparams, [:pointer, :pointer], :void
  attach_function :btck_context_options_destroy, [:pointer], :void

  # Context
  attach_function :btck_context_create, [:pointer], :pointer
  attach_function :btck_context_destroy, [:pointer], :void
  attach_function :btck_context_interrupt, [:pointer], :int

  # Chainstate manager options
  attach_function :btck_chainstate_manager_options_create, [:pointer, :string, :size_t, :string, :size_t], :pointer
  attach_function :btck_chainstate_manager_options_set_worker_threads_num, [:pointer, :int], :void
  attach_function :btck_chainstate_manager_options_destroy, [:pointer], :void

  # Chainstate manager
  attach_function :btck_chainstate_manager_create, [:pointer], :pointer
  attach_function :btck_chainstate_manager_process_block, [:pointer, :pointer, :pointer], :int
  attach_function :btck_chainstate_manager_get_active_chain, [:pointer], :pointer
  attach_function :btck_chainstate_manager_get_block_tree_entry_by_hash, [:pointer, :pointer], :pointer
  attach_function :btck_chainstate_manager_destroy, [:pointer], :void

  # Block
  attach_function :btck_block_create, [:pointer, :size_t], :pointer
  attach_function :btck_block_copy, [:pointer], :pointer
  attach_function :btck_block_count_transactions, [:pointer], :size_t
  attach_function :btck_block_get_transaction_at, [:pointer, :size_t], :pointer
  attach_function :btck_block_get_hash, [:pointer], :pointer
  attach_function :btck_block_destroy, [:pointer], :void

  # Block hash
  attach_function :btck_block_hash_create, [:pointer], :pointer
  attach_function :btck_block_hash_to_bytes, [:pointer, :pointer], :void
  attach_function :btck_block_hash_destroy, [:pointer], :void

  # Block validation state
  attach_function :btck_block_validation_state_get_validation_mode, [:pointer], :uint8
  attach_function :btck_block_validation_state_get_block_validation_result, [:pointer], :uint32

  # Chain
  attach_function :btck_chain_get_height, [:pointer], :int32
  attach_function :btck_chain_get_by_height, [:pointer, :int], :pointer

  # Block tree entry
  attach_function :btck_block_tree_entry_get_height, [:pointer], :int32
  attach_function :btck_block_tree_entry_get_block_hash, [:pointer], :pointer

  # Transaction
  attach_function :btck_transaction_create, [:pointer, :size_t], :pointer
  attach_function :btck_transaction_copy, [:pointer], :pointer
  attach_function :btck_transaction_count_outputs, [:pointer], :size_t
  attach_function :btck_transaction_count_inputs, [:pointer], :size_t
  attach_function :btck_transaction_get_output_at, [:pointer, :size_t], :pointer
  attach_function :btck_transaction_get_input_at, [:pointer, :size_t], :pointer
  attach_function :btck_transaction_get_txid, [:pointer], :pointer
  attach_function :btck_transaction_destroy, [:pointer], :void

  # Transaction output
  attach_function :btck_transaction_output_create, [:pointer, :int64], :pointer
  attach_function :btck_transaction_output_get_script_pubkey, [:pointer], :pointer
  attach_function :btck_transaction_output_get_amount, [:pointer], :int64
  attach_function :btck_transaction_output_destroy, [:pointer], :void

  # Script pubkey
  attach_function :btck_script_pubkey_create, [:pointer, :size_t], :pointer
  attach_function :btck_script_pubkey_verify, [:pointer, :int64, :pointer, :pointer, :size_t, :uint, :uint32, :pointer], :int
  attach_function :btck_script_pubkey_destroy, [:pointer], :void

  # Txid
  attach_function :btck_txid_to_bytes, [:pointer, :pointer], :void
  attach_function :btck_txid_destroy, [:pointer], :void

  # Transaction input
  attach_function :btck_transaction_input_get_out_point, [:pointer], :pointer
  attach_function :btck_transaction_input_destroy, [:pointer], :void

  # Transaction out point
  attach_function :btck_transaction_out_point_get_index, [:pointer], :uint32
  attach_function :btck_transaction_out_point_get_txid, [:pointer], :pointer
  attach_function :btck_transaction_out_point_destroy, [:pointer], :void

  autoload :Block, 'bitcoinkernel/block'
  autoload :BlockHash, 'bitcoinkernel/block_hash'
  autoload :Transaction, 'bitcoinkernel/transaction'
  autoload :TransactionInput, 'bitcoinkernel/transaction_input'
  autoload :TransactionOutPoint, 'bitcoinkernel/transaction_out_point'
  autoload :TransactionOutput, 'bitcoinkernel/transaction_output'
  autoload :ScriptPubkey, 'bitcoinkernel/script_pubkey'
  autoload :ChainParameters, 'bitcoinkernel/chain_parameters'
  autoload :ContextOptions, 'bitcoinkernel/context_options'
  autoload :Context, 'bitcoinkernel/context'
  autoload :ChainstateManagerOptions, 'bitcoinkernel/chainstate_manager_options'
  autoload :ChainstateManager, 'bitcoinkernel/chainstate_manager'
  autoload :Chain, 'bitcoinkernel/chain'
  autoload :BlockTreeEntry, 'bitcoinkernel/block_tree_entry'
end
