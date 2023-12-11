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
            @map.columns.each_with_index.reverse_each do |column, _index|
              next if column.flatten.include? "#"

              column.each { |cell| cell << :c }
            end
            @map.rows.each_with_index.reverse_each do |row, _index|
              next if row.flatten.include? "#"

              row.each { |cell| cell << :r }
            end
          end

          def find_galaxies
            @galaxies = {}
            @map.cells_with_row_column.each do |cell, row, column|
              @galaxies["#{row}_#{column}"] = { row:, column: } if cell.include? "#"
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
            @map.path_to_cells([{ row: g1[:row], column: g1[:column] }, { row: g1[:row], column: g2[:column] }]).each do |cell|
              length += if cell.include? :c
                          @expansion
                        else
                          1
                        end
            end
            @map.path_to_cells([{ row: g1[:row], column: g2[:column] }, { row: g2[:row], column: g2[:column] }]).each do |cell|
              length += if cell.include? :r
                          @expansion
                        else
                          1
                        end
            end
            length
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            @expansion = 2
            puts @map
            expand_universe
            puts @map
            find_galaxies
            find_paths
            # puts @map
            @total_paths = @paths.values.sum
            logger.warn "Star one answer: #{@total_paths}"
          end

          def star_two
            @expansion = 1_000_000
            find_galaxies
            find_paths
            @total_paths = @paths.values.sum
            logger.warn "Star two answer: #{@total_paths}"
          end
        end
      end
    end
  end
end
