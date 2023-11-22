# frozen_string_literal: true

require_relative "advent_of_code/version"
require_relative "advent_of_code/cli"

module Bauk
  # Main module for all the AdventOfCode challenges
  module AdventOfCode
    class Error < StandardError; end

    def self.parse(options)
      CLI.new.parse(options)
    end
  end
end
