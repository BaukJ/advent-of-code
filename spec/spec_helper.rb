# frozen_string_literal: true

require "bauk/advent_of_code"

# Disable logging by setting log level to above ERROR/3
logger = Bauk::AdventOfCode::Logger::Singleton.instance.logger
logger.level = 4

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
