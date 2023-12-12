# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge12
        # Challenge for 2023/12
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @arrangements = []
            @rows = []
            @lines = @lines.map do |line|
              parts = line.split
              @arrangements << parts[1].split(",").map(&:to_i)
              @rows << parts[0].chars
              parts[0]
            end
            @map = Map.from_lines @lines
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def find_combinations(row, arrangement, current_arrangement = [], chain = 0)
            logger.debug "Finding combinations for #{row.join} / #{arrangement.join}"
            combinations = 0
            row.each_with_index do |char, index|
              logger.debug { "Current start: #{current_arrangement.inspect} + #{chain}"}
              if char == "?"
                if arrangement.length == current_arrangement.length
                  char = "."
                else
                  combinations += find_combinations(["."] + row[(index+1)..], arrangement, current_arrangement.clone, chain)
                  combinations += find_combinations(["#"] + row[(index+1)..], arrangement, current_arrangement.clone, chain)
                  return combinations
                end
              end
              case char
              when "#" then chain += 1
              when "."
                if chain.positive?
                  current_arrangement << chain
                  chain = 0
                end
              else die "Invalid char: #{char}"
              end
              return 0 unless valid?(current_arrangement, arrangement)
              logger.debug { "Current: #{current_arrangement.inspect} + #{chain}"}
            end
            current_arrangement << chain if chain.positive?
            logger.debug { "Final chain: #{current_arrangement.inspect}"}
            if valid?(current_arrangement, arrangement) && arrangement.length == current_arrangement.length
              logger.info "Success! #{arrangement} / #{current_arrangement}"
              combinations += 1
            end
            combinations
          end

          def valid?(current_arrangement, arrangement)
            valid = true
            current_arrangement.each_with_index do |a, i|
              valid = false if a != arrangement[i]
            end
            # TODO: can use spece left too
            valid
          end

          def valid_combination
          end

          def star_one
            puts @map
            @total = 0
            @rows.each_with_index do |row, index|
              arrangement = @arrangements[index]
              @total += find_combinations row, arrangement
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
