# frozen_string_literal: true

require "optparse"
require_relative "base_class"
Dir[File.join(__dir__, "year_*", "challenge_*", "*.rb")].sort.each { |file| require file }

module Bauk
  module AdventOfCode
    # Class providing the CLI interfact
    class CLI < BaseClass
      Options = Struct.new(:year, :challenge)

      def initialize
        super
        @opts = Options.new
        @parser = OptionParser.new do |opts|
          opts.banner = "Usage: advent-of-code <year> <challenge> [options]"
          add_opts(opts)
          add_utility_opts(opts)
        end
      end

      def add_utility_opts(opts)
        opts.on("-v", "Increase verbosity") do
          logger.level = ::Logger::INFO
        end
      end

      def add_opts(opts)
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
        opts.on("--version", "Prints the program version") do
          puts VERSION
          exit
        end
      end

      def parse(options)
        @parser.order_recognized!(options)
        if options.length < 2
          die "You need to pass the year and challenge"
          puts @parser
          exit 3
        end
        year = options.shift
        challenge = options.shift
        parse_challenge year, challenge, options
      end

      def parse_challenge(year, challenge, options)
        challenge_module = get_challenge_module(year, challenge)
        begin
          challenge_class = challenge_module.const_get("Challenge").new
        rescue NameError => e
          puts e
          die "Year/Challenge of #{year}/#{challenge} did not bring back a challenge class"
        end
        parse_challenge_options(challenge_module, options)
        challenge_class.run
      end

      def parse_challenge_options(challenge_module, options)
        challenge_options = challenge_module.const_get "Options"
        challenge_options.parse(@parser)
      rescue NameError => e
        puts e
        logger.info "Options not found for #{year}/#{challenge}"
      ensure
        @parser.parse!(options)
      end

      def get_challenge_module(year, challenge)
        ["Year#{year}", "Challenge#{challenge}"].inject(AdventOfCode) do |o, c|
          o.const_get c
        end
      rescue NameError => e
        puts e
        die "Year/Challenge of #{year}/#{challenge} did not bring back a module"
      end
    end
  end
end

# Patch to allow ignoring of unknown options
class OptionParser
  # Like order!, but leave any unrecognized --switches alone
  def order_recognized!(args)
    extra_opts = []
    begin
      order!(args) { |a| extra_opts << a }
    rescue OptionParser::InvalidOption => e
      extra_opts << e.args[0]
      retry
    end
    args[0, 0] = extra_opts
  end
end
