# frozen_string_literal: true

require_relative "../../base_challenge"
require_relative "map"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge03
        # Challenge for 2023/03
        class Challenge < BaseChallenge
          def initialize
            super
            @map = Map.from_file File.join(__dir__, Opts.file)
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            @map.cells_with_row_column.each do |cell, row, column|
              next if cell.empty? || cell[0] =~ /[0-9]/

              find_adjacent_numbers(row, column)
            end
            logger.warn "Star one answer: #{@numbers_map.values.sum}"
          end

          def find_adjacent_numbers(row, column)
            @numbers_map ||= {}
            @gears ||= []
            numbers_map = {}
            @map.adjacent_8_cells_with_row_column(row, column).each do |cell, r, c|
              next if cell.empty? || cell[0] !~ /[0-9]/

              number, ri, ci = get_number_with_rc(r, c)
              numbers_map["#{ri}_#{ci}"] = number
            end
            @numbers_map.merge! numbers_map
            return if numbers_map.size != 2

            puts numbers_map.values.inspect
            @gears << numbers_map.values.inject(1) { |x, y| x * y }
          end

          def get_number_with_rc(row, column)
            number = @map.cell(row, column)[0]
            start_column = column
            (0...column).to_a.reverse.each do |c|
              cell = @map.cell(row, c)
              break if cell.empty? || cell[0] !~ /[0-9]/

              number = cell[0] + number
              start_column = c
            end
            ((column + 1)..@map.column_max_index).to_a.each do |c|
              cell = @map.cell(row, c)
              break if cell.empty? || cell[0] !~ /[0-9]/

              number += cell[0]
            end
            logger.debug { "Found number: #{row}/#{start_column} => #{number}" }
            [number.to_i, row, start_column]
          end

          def star_two
            logger.warn "Star two answer: #{@gears.sum}"
          end
        end
      end
    end
  end
end
