# frozen_string_literal: true

require "optparse"
require "logger"

module Bauk
  module AdventOfCode
    # Mixin providing the logging framework for this gem
    module Logger
      # Provide one logger for the whole program
      class Singleton
        attr_reader :logger

        def initialize
          @logger = ::Logger.new($stdout)
          @logger.level = ::Logger::WARN
          @logger.formatter = proc do |severity, datetime, _progname, msg|
            "#{datetime.strftime("%H:%M:%S")}(#{severity.ljust(5)}) #{msg}\n"
          end
          logger.debug "Creating logger"
        end

        def self.instance
          @instance ||= Singleton.new
        end
      end

      def self.static
        Singleton.instance.logger
      end

      def logger
        @logger ||= Singleton.instance.logger
      end

      def die(message = nil)
        logger.error message unless message.nil?
        logger.error yield if block_given?
        raise Error, message
      end
    end
  end
end
