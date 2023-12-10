# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge10
        # Map for 2023/10
        class Map < BaseMap
          Pipes = {
            "|" => %i[up down],
            "-" => %i[left right],
            "L" => %i[up right],
            "J" => %i[up left],
            "7" => %i[down left],
            "F" => %i[down right],
            "S" => %i[up down left right],
          }.freeze

          def self.cell_from_char(char, row, column)
            return [] if char == "."
            raise "Invalid cell: #{char}" unless Pipes.keys.include? char

            cell = { char:, connections: [] }
            Pipes[char].each do |direction|
              case direction
              when :up then cell[:connections] << {row: row - 1, column: }
              when :down then cell[:connections] << {row: row + 1, column: }
              when :left then cell[:connections] << {row:, column: column - 1 }
              when :right then cell[:connections] << {row:, column: column + 1}
              else die "Invalid cell: #{char}"
              end
            end
            cell[:connections].select! do |c|
              c[:row] >= 0 && c[:column] >= 0
            end
            cell
          end

          def cell_to_s(cell, row_index, column_index)
            if cell.empty? then "."
            else
              cell[:char]
            end
          end
        end
      end
    end
  end
end
