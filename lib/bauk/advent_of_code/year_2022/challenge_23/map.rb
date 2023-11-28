# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge23
        # Map for 2022/23
        class Map < BaseMap
          attr_accessor :directions, :plan_map, :moves

          def initialize(row_count, column_count)
            super
            @directions = %i[north south east west]
            @plan_map = nil
            @moves = 0
          end

          def rotate_directions
            @directions = @directions[1..] + [@directions[0]]
          end

          def update_item(row_index, column_index, item, new_map)
            available_directions = get_directions row_index, column_index, self
            if (@plan_map && !plan_ok?(row_index, column_index)) || available_directions[:all] || !available_directions[:any]
              new_map.insert(row_index, column_index, item)
              return
            end

            @directions.each do |direction|
              next unless available_directions[direction][:empty]

              new_map.insert available_directions[direction][:row], available_directions[direction][:column], item
              @moves += 1
              return # rubocop:disable Lint/NonLocalExitFromIterator
            end
            die "Could not find place to put elf"
          end

          def plan!
            @allow_multiples = true
            @plan_map = update
            @allow_multiples = false
          end

          def update
            @moves = 0
            new_map = super
            new_map.plan_map = nil
            new_map.moves = @moves
            new_map
          end

          def plan_ok?(row, column)
            # Make sure all the moved he could make all don't have 2 elves
            @plan_map.adjacent_4_cells(row, column).map { |cell| cell.length <= 1 }.all?
          end

          def get_directions(row, column, map = self) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
            n = map.empty? row - 1, column
            ne = map.empty? row - 1, column + 1
            nw = map.empty? row - 1, column - 1
            e = map.empty? row, column + 1
            w = map.empty? row, column - 1
            s = map.empty? row + 1, column
            se = map.empty? row + 1, column + 1
            sw = map.empty? row + 1, column - 1
            spaces = {
              north: { empty: ne && n && nw, row: row - 1, column: },
              east: { empty: ne && e && se, row:, column: column + 1 },
              south: { empty: se && s && sw, row: row + 1, column: },
              west: { empty: nw && w && sw, row:, column: column - 1 }
            }
            spaces[:any] = @directions.map { |d| spaces[d][:empty] }.any?
            spaces[:all] = @directions.map { |d| spaces[d][:empty] }.all?
            spaces
          end
        end
      end
    end
  end
end
