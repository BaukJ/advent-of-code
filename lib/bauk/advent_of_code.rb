# frozen_string_literal: true

require_relative "advent_of_code/version"
require_relative "advent_of_code/cli"
require_relative "advent_of_code/logger"

module Bauk
  module AdventOfCode
    class Error < StandardError; end

    include Logger
    def self.parse(options)
      puts CLI.new.parse(options)
    end
  end
end
