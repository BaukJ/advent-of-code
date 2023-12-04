# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge06
        # Challenge for 2022/06
        class Challenge < BaseChallenge
          def initialize
            super
            @line = File.read File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            logger.warn "Star one answer: #{star 4}"
            logger.warn "Star two answer: #{star 14}"
          end

          def star(length)
            chars = []
            @line.chars.each_with_index do |char, index|
              chars << char
              next if chars.length < length
              return index + 1 if chars[-length..].uniq.length == length
            end
            die "Did not find a terminator"
          end
        end
      end
    end
  end
end
