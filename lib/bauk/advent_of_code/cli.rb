# frozen_string_literal: true

require "optparse"
require_relative "base_class"
Dir[File.join(__dir__, "year_*", "challenge_*", "*.rb")].each { |file| require file }

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
          logger.level = case logger.level
                         when ::Logger::INFO then ::Logger::DEBUG
                         else ::Logger::INFO
                         end
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
        # @parser.order_recognized!(options) # Don't do this first, so -h will show all options
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
        add_challenge_opts_map challenge_module, year, challenge
        parse_challenge_options(challenge_module, options, year, challenge)
        begin
          challenge_class = challenge_module.const_get("Challenge").new
        rescue NameError => e
          logger.error "Year/Challenge of #{year}/#{challenge} did not bring back a challenge class"
          raise e
        end
        run_challenge challenge_class
      end

      def run_challenge(challenge_class)
        challenge_class.run
      rescue Interrupt => e
        logger.error "Interupted with Ctrl+C"
      end

      def parse_challenge_options(challenge_module, options, year, challenge)
        challenge_options = challenge_module.const_get "Options"
        challenge_options.parse(@parser)
      rescue NameError => e
        puts e
        logger.info "Options not found for #{year}/#{challenge}"
      ensure
        @parser.parse!(options)
      end

      def add_challenge_opts_map(challenge_module, year, challenge)
        challenge_opts = challenge_module.const_get "Opts"
        challenge_opts.to_h.each do |key, default_value|
          add_challenge_opt challenge_opts, key, default_value
        end
      rescue NameError => e
        logger.info "OptsMap not found for #{year}/#{challenge}"
        raise e
      end

      def add_challenge_opt(challenge_opts, key, default_value)
        if default_value == false
          @parser.on("--#{key.to_s.gsub "_", "-"}", default_value.class) do
            challenge_opts[key] = true
          end
        else
          @parser.on("--#{key.to_s.gsub "_", "-"}=VALUE", default_value.class) do |value|
            challenge_opts[key] = value
          end
        end
      end

      def get_challenge_module(year, challenge)
        ["Year#{year}", "Challenge#{challenge}"].inject(AdventOfCode) do |o, c|
          o.const_get c
        end
      rescue NameError => e
        logger.error "Year/Challenge of #{year}/#{challenge} did not bring back a module"
        raise e
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
