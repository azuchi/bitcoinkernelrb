# frozen_string_literal: true

ENV['LIB_BITCOINKERNEL_PATH'] ||= File.expand_path('lib/libbitcoinkernel.so', File.dirname(__FILE__))

require "bitcoinkernel"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
