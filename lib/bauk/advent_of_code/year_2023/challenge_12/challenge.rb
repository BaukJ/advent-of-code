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
            # star_one
            star_two
          end

          def find_combinations(row, arrangement)
            combinations = find_combination(row, arrangement)
            logger.info "Found combinations for #{row.join} / #{arrangement.join} => #{combinations}"
            combinations
          end

          def find_combination(row, arrangement, current_arrangement = [], chain = 0) # rubocop:disable Metrics/AbcSize
            # logger.debug { "ROW: #{row}" }
            combinations = 0
            row.each_with_index do |char, index| # rubocop:disable Metrics/BlockLength
              # logger.debug { "Current start: #{current_arrangement.inspect} + #{chain}"}
              if char == "?"
                if arrangement.length == current_arrangement.length
                  char = "."
                elsif chain.positive?
                  if chain < arrangement[current_arrangement.length]
                    # Must be broken if chain needs to be longer
                    char = "#"
                  else
                    char = "."
                  end
                elsif !can_start_chain?(row[index..], arrangement[current_arrangement.length])
                  char = "."
                else
                  combinations += find_combination(["."] + row[(index+1)..], arrangement, current_arrangement.clone, chain)
                  combinations += find_combination(["#"] + row[(index+1)..], arrangement, current_arrangement.clone, chain)
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
              return 0 unless chain.positive? || valid?(current_arrangement, arrangement, chain, row[index+1..])

              # logger.debug { "Current: #{current_arrangement.inspect} + #{chain}"}
            end
            current_arrangement << chain if chain.positive?
            # logger.debug { "Final chain: #{current_arrangement.inspect}"}
            if valid?(current_arrangement, arrangement) && arrangement.length == current_arrangement.length
              combinations += 1
            end
            combinations
          end

          def can_start_chain?(rows_left, chain_length)
            (0...chain_length).each do |i|
              return false if rows_left[i] == "."
            end
            true
          end

          def valid?(current_arrangement, arrangement, chain = 0, rows_left = []) # rubocop:disable Metrics/AbcSize
            current_arrangement.each_with_index do |a, i|
              return false if a != arrangement[i]
            end
            if chain.positive?
              return false if current_arrangement.length >= arrangement.length || chain > arrangement[current_arrangement.length]
            end
            # See if we have enough rows left to comply
            broken_left = 0
            min_length = (current_arrangement.length...arrangement.length).each.inject(0) do |length, index|
              length += 1 if length != 0
              broken_left += arrangement[index]
              length += arrangement[index]
              length
            end - chain
            return false if min_length > rows_left.length
            return false if rows_left.select {|r| r == "?" || r == "#" }.length < arrangement[current_arrangement.length..].sum - chain

            true
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
            @times = 5
            @rows.map! do |row|
              (1..@times).map { row.join() }.join("?").chars
            end
            @arrangements.map! do |arrangement|
              (1..@times).inject([]) { |obj, i| obj + arrangement }
            end
            @total = 0
            @rows.each_with_index do |row, index|
              arrangement = @arrangements[index]
              @total += find_combinations row, arrangement
              # break
            end
            logger.warn "Star two answer: #{@total}"
          end
        end
      end
    end
  end
end
