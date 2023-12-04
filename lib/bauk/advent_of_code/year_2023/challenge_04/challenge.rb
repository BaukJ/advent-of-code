# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge04
        # Challenge for 2023/04
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

          def star_one # rubocop:disable Metrics/AbcSize
            @total_count = 0
            counts = {}
            @total = 0
            @lines.each_with_index do |line, index|
              counts[index] ||= 1
              die "Invalid line: #{line}" unless line.sub!(/^Card  *#{index + 1}: /, "")

              winning_numbers = line.split("|")[0].split
              my_numbers = line.split("|")[1].split
              won_numbers = winning_numbers & my_numbers
              logger.debug { "Won numbers: #{won_numbers}" }
              unless won_numbers.empty?
                @total += 2**(won_numbers.length - 1)
                (1..won_numbers.length).each do |n|
                  counts[index + n] ||= 1
                  counts[index + n] += counts[index]
                end
                puts counts.inspect
              end
              logger.debug { "TOTAL: #{@total}" }
              @total_count += counts[index]
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            logger.warn "Star two answer: #{@total_count}"
          end
        end
      end
    end
  end
end
