# BitcoinKernel

Ruby bindings for [libbitcoinkernel](https://github.com/bitcoin/bitcoin/blob/master/doc/design/libraries.md#libbitcoinkernel), the Bitcoin Core consensus engine library.

## Requirements

- Ruby 3.0+
- libbitcoinkernel shared library

You need to build libbitcoinkernel from Bitcoin Core source:

```bash
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
cmake -B build -DBUILD_KERNEL_LIB=ON -DBUILD_SHARED_LIBS=ON
cmake --build build
```

Set the `LIB_BITCOINKERNEL_PATH` environment variable to point to the built library:

```bash
export LIB_BITCOINKERNEL_PATH=/path/to/bitcoin/build/src/kernel/libbitcoinkernel.so
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitcoinkernel'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install bitcoinkernel
```

## Usage

### Basic Block Parsing

```ruby
require 'bitcoinkernel'

# Parse a block from raw bytes
block_hex = "0100000000000000..."
block = BitcoinKernel::Block.from_raw([block_hex].pack('H*'))

# Access block properties
puts block.block_hash.to_hex
puts "Transaction count: #{block.transaction_count}"

# Iterate transactions
block.transactions.each do |tx|
  puts "Txid: #{tx.txid.to_hex}"
  puts "Inputs: #{tx.input_count}, Outputs: #{tx.output_count}"
end

# Serialize back to bytes
raw_bytes = block.to_bytes
```

### Transaction Parsing

```ruby
# Parse a transaction
tx = BitcoinKernel::Transaction.from_raw(raw_tx_bytes)

# Access inputs
tx.inputs.each do |input|
  out_point = input.out_point
  puts "Spending #{out_point.txid.to_hex}:#{out_point.index}"
end

# Access outputs
tx.outputs.each_with_index do |output, i|
  puts "Output #{i}: #{output.amount} satoshis"
end
```

### Script Verification

```ruby
# Verify a script
script = BitcoinKernel::ScriptPubkey.from_raw(script_bytes)

result = script.verify(
  amount: 50_0000_0000,  # in satoshis
  tx: spending_tx,
  input_index: 0,
  flags: BitcoinKernel::ScriptFlags::ALL
)

puts result ? "Valid" : "Invalid"
```

### Chainstate Management

```ruby
# Disable logging (optional)
BitcoinKernel::Logging.disable

# Create context with chain parameters
options = BitcoinKernel::ContextOptions.create
params = BitcoinKernel::ChainParameters.regtest  # or .mainnet, .testnet, etc.
options.set_chainparams(params)
context = BitcoinKernel::Context.create(options)

# Create chainstate manager
cs_options = BitcoinKernel::ChainstateManagerOptions.create(
  context: context,
  data_directory: "/path/to/data",
  blocks_directory: "/path/to/blocks"
)
cs_options.set_block_tree_db_in_memory
cs_options.set_chainstate_db_in_memory

manager = BitcoinKernel::ChainstateManager.create(cs_options)

# Process blocks
block = BitcoinKernel::Block.from_raw(block_bytes)
manager.process_block(block)

# Query the chain
chain = manager.active_chain
puts "Chain height: #{chain.height}"

entry = chain.entry_at(0)
puts "Genesis hash: #{entry.block_hash.to_hex}"
```

### Validation Interface

```ruby
# Create a custom validation interface
class MyValidationInterface < BitcoinKernel::ValidationInterface
  def block_checked(block, state)
    if state.valid?
      puts "Block valid: #{block.block_hash.to_hex}"
    else
      puts "Block invalid"
    end
  end

  def block_connected(block, entry)
    puts "Block connected at height #{entry.height}"
  end
end

# Use with context
vi = MyValidationInterface.new
options = BitcoinKernel::ContextOptions.create
options.set_validation_interface(vi)
context = BitcoinKernel::Context.create(options)
```

### Logging Configuration

```ruby
# Disable all logging
BitcoinKernel::Logging.disable

# Or configure logging options
BitcoinKernel::Logging.set_options(
  timestamps: true,
  time_micros: false,
  threadnames: false,
  sourcelocations: false,
  category_levels: true
)

# Set log level for specific category
BitcoinKernel::Logging.set_level(
  BitcoinKernel::Logging::Category::VALIDATION,
  BitcoinKernel::Logging::Level::DEBUG
)

# Enable/disable categories
BitcoinKernel::Logging.enable_category(BitcoinKernel::Logging::Category::ALL)
BitcoinKernel::Logging.disable_category(BitcoinKernel::Logging::Category::MEMPOOL)
```

## API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `Block` | Bitcoin block with header and transactions |
| `BlockHash` | 32-byte block hash |
| `Transaction` | Bitcoin transaction |
| `Txid` | 32-byte transaction ID |
| `TransactionInput` | Transaction input |
| `TransactionOutput` | Transaction output with amount and script |
| `TransactionOutPoint` | Reference to a previous output (txid + index) |
| `ScriptPubkey` | Output script with verification support |

### Chain Management

| Class | Description |
|-------|-------------|
| `Context` | Kernel context for chain operations |
| `ContextOptions` | Configuration for context creation |
| `ChainParameters` | Network parameters (mainnet, testnet, regtest, etc.) |
| `ChainstateManager` | Manages blockchain state and validation |
| `ChainstateManagerOptions` | Configuration for chainstate manager |
| `Chain` | Active blockchain view |
| `BlockTreeEntry` | Entry in the block tree |
| `BlockValidationState` | Validation result for a block |
| `ValidationInterface` | Callbacks for validation events |

### Constants

| Module | Description |
|--------|-------------|
| `ChainType` | Network types (MAINNET, TESTNET, REGTEST, etc.) |
| `ScriptFlags` | Script verification flags |
| `ValidationMode` | Block validation modes |
| `BlockValidationResult` | Validation failure reasons |
| `Logging::Category` | Log categories |
| `Logging::Level` | Log levels (TRACE, DEBUG, INFO) |

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).