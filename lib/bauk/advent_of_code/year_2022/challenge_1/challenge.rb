# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge1
        # Challenge for 2022/1
        class Challenge < BaseChallenge
          def initialize
            super
            # @base_map = Map.from_s(File.read(File.join(__dir__, Opts.map_file)))
            @base_map = Map.new(10, 10)
            @maps = [@base_map]
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            puts @maps
          end
        end
      end
    end
  end
end
