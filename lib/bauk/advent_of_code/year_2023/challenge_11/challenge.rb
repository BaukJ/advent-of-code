# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge11
        # Challenge for 2023/11
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
          end

          def expand_universe
            @map.columns.each_with_index.reverse_each do |column, index|
              @map.insert_column(index) if column.flatten.empty?
            end
            @map.rows.each_with_index.reverse_each do |row, index|
              @map.insert_row(index) if row.flatten.empty?
            end
          end

          def find_galaxies
            @galaxies = {}
            @map.cells_with_row_column.each do |cell, row, column|
              @galaxies["#{row}_#{column}"] = {row:, column:} unless cell.empty?
            end
          end

          def g_key(cell)
            "#{cell[:row]}_#{cell[:column]}"
          end

          def path_key(cell_x, cell_y)
            "#{cell_x[:row]}_#{cell_x[:column]}___#{cell_y[:row]}_#{cell_y[:column]}"
          end

          def find_paths
            @paths = {}
            @galaxies.each do |key1, galaxy1|
              @galaxies.each do |key2, galaxy2|
                key = path_key(galaxy1, galaxy2)
                break if key1 == key2 || @paths[path_key(galaxy2, galaxy1)] || @paths[key]

                @paths[key] = find_path(galaxy1, galaxy2)
              end
            end
          end

          def find_path(g1, g2)
            length = 0
            length += (g1[:row] - g2[:row]).abs
            length += (g1[:column] - g2[:column]).abs
            length
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            puts @map
            expand_universe
            find_galaxies
            find_paths
            # puts @map
            @total_paths = @paths.values.sum
            logger.warn "Star one answer: #{@total_paths}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
