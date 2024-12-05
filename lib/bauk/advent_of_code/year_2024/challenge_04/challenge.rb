# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge04
        # Challenge for 2024/04
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = @lines.map(&:chars)
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one if [0, 1].include? Opts.star
            star_two if [0, 2].include? Opts.star
          end

          def star_one
            total = 0
            @map.each_with_index do |cells, row|
              cells.each_with_index do |cell, column|
                next unless cell == "X"

                lines = [
                  [{ row:, column: column + 1 }, { row:, column: column + 2 }, { row:, column: column + 3 }],
                  [{ row:, column: column - 1 }, { row:, column: column - 2 }, { row:, column: column - 3 }],
                  [{ row: row + 1, column: }, { row: row + 2, column: }, { row: row + 3, column: }],
                  [{ row: row - 1, column: }, { row: row - 2, column: }, { row: row - 3, column: }],
                  [{ row: row - 1, column: column - 1 }, { row: row - 2, column: column - 2 }, { row: row - 3, column: column - 3 }],
                  [{ row: row + 1, column: column - 1 }, { row: row + 2, column: column - 2 }, { row: row + 3, column: column - 3 }],
                  [{ row: row - 1, column: column + 1 }, { row: row - 2, column: column + 2 }, { row: row - 3, column: column + 3 }],
                  [{ row: row + 1, column: column + 1 }, { row: row + 2, column: column + 2 }, { row: row + 3, column: column + 3 }]
                ]
                lines.each do |positions|
                  next if positions[2][:row].negative? || positions[2][:column].negative?
                  next unless @map[positions[0][:row]]&.[](positions[0][:column]) == "M" &&
                              @map[positions[1][:row]]&.[](positions[1][:column]) == "A" &&
                              @map[positions[2][:row]]&.[](positions[2][:column]) == "S"

                  total += 1
                end
                # puts "Found X at: #{row}/#{column}"
              end
            end
            logger.warn "Star one answer: #{total}"
          end

          def star_two
            total = 0
            @map.each_with_index do |cells, row|
              cells.each_with_index do |cell, column|
                next unless cell == "A"

                lines = [
                  [{ row: row - 1, column: column - 1 }, { row: row + 1, column: column + 1 }],
                  # [{ row: row + 1, column: column + 1 }, { row: row - 1, column: column - 1 }],
                  [{ row: row - 1, column: column + 1 }, { row: row + 1, column: column - 1 }]
                  # [{ row: row + 1, column: column - 1 }, { row: row - 1, column: column + 1 }]
                ]
                mas_count = 0
                lines.each do |positions|
                  next if positions.any? { |pos| pos[:row].negative? || pos[:column].negative? }
                  next unless (@map[positions[0][:row]]&.[](positions[0][:column]) == "M" &&
                              @map[positions[1][:row]]&.[](positions[1][:column]) == "S") ||
                              (@map[positions[0][:row]]&.[](positions[0][:column]) == "S" &&
                              @map[positions[1][:row]]&.[](positions[1][:column]) == "M")

                  mas_count += 1
                end
                total += 1 if mas_count == 2
                # puts "Found X at: #{row}/#{column}"
              end
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
