# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge04
        # Challenge for 2022/04
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

          def star_one
            @complete_overlaps = 0
            @lines.each do |line|
              start_one, end_one, start_two, end_two = line.split(/[,-]/).map(&:to_i)
              @complete_overlaps += 1 if (start_one >= start_two && end_one <= end_two) || (start_two >= start_one && end_two <= end_one)
            end
            logger.warn "Star one answer: #{@complete_overlaps}"
          end

          def star_two
            @overlaps = 0
            @lines.each do |line|
              start_one, end_one, start_two, end_two = line.split(/[,-]/).map(&:to_i)
              @overlaps += 1 if (start_one..end_one).any? { |i| i.between?(start_two, end_two) }
            end
            logger.warn "Star two answer: #{@overlaps}"
          end
        end
      end
    end
  end
end
