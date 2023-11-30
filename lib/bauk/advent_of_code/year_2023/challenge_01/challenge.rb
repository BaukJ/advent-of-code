# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge01
        # Challenge for 2023/01
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            puts @lines
            star_one
            star_two
          end

          def star_one
            logger.warn "Start 1 answer: "
          end

          def star_two
            logger.warn "Start 1 answer: "
          end
        end
      end
    end
  end
end
