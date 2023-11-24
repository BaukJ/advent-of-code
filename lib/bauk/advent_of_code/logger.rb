# frozen_string_literal: true

require "optparse"
require "logger"

module Bauk
  module AdventOfCode
    # Mixin providing the logging framework for this gem
    module Logger
      # @@logger = ::Logger.new(STDOUT)
      @@logger = nil

      def logger
        unless @@logger
          @@logger = ::Logger.new($stdout)
          @@logger.level = ::Logger::WARN
        end
        @@logger
      end

      def die(message)
        logger.error message
        exit 1
      end
    end
  end
end
