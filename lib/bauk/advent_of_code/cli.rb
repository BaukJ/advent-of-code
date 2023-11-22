# frozen_string_literal: true

require "optparse"
require_relative "base_class"
Dir[File.join(__dir__, "year_2022", "*.rb")].sort.each { |file| require file }

module Bauk
  module AdventOfCode
    # Class providing the CLI interfact
    class CLI < BaseClass
      Options = Struct.new(:year, :challenge)

      def initialize
        super
        @opts = Options.new
        @parser = OptionParser.new do |opts|
          opts.banner = "Usage: advent-of-code [options]"
          add_opts(opts)
          add_utility_opts(opts)
        end
      end

      def add_utility_opts(opts)
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
        opts.on("--version", "Prints the program version") do
          puts VERSION
          exit
        end
      end

      def add_opts(opts)
        opts.on("-y", "--year=YEAR", "Year to use") do |n|
          @opts.year = n
        end
        opts.on("-c", "--challenge=24", "Challenge to use") do |n|
          @opts.challenge = n
        end
      end

      def parse(options)
        @parser.parse!(options)
        begin
          challenge = ["Year#{@opts.year}", "Challenge#{@opts.challenge}"].inject(AdventOfCode) do |o, c|
            o.const_get c
          end.new
        rescue NameError
          die "Year/Challenge of #{@opts.year}/#{@opts.challenge} did not bring back a class"
        end
        challenge.run
      end
    end
  end
end
