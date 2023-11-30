# frozen_string_literal: true

require "bauk/advent_of_code"

logger = Bauk::AdventOfCode::Logger::Singleton.instance.logger
puts logger.level
logger.level = ::Logger::ERROR
logger.level = 4
puts logger.level

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
