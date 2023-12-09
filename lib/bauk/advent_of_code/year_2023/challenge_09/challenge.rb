# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge09
        # Challenge for 2023/09
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def difference_list(list)
            (1...list.length).map do |i|
              list[i] - list[i - 1]
            end
          end

          def guess_next(sequence)
            sequence[-1] << 0
            (0...(sequence.length - 1)).to_a.reverse.each do |i|
              sequence[i] << (sequence[i][-1] + sequence[i + 1][-1])
            end
          end

          def guess_previous(sequence)
            sequence[-1].unshift 0
            (0...(sequence.length - 1)).to_a.reverse.each do |i|
              sequence[i].unshift sequence[i][0] - sequence[i + 1][0]
            end
          end

          def star_one
            @total = 0
            @previous_total = 0
            @lines.each do |line|
              sequence = [line.split.map(&:to_i)]
              sequence << difference_list(sequence[-1]) while sequence[-1].sum != 0
              logger.debug sequence.inspect
              guess_next sequence
              guess_previous sequence
              logger.debug sequence.inspect
              @total += sequence[0][-1]
              @previous_total += sequence[0][0]
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            logger.warn "Star two answer: #{@previous_total}"
          end
        end
      end
    end
  end
end
