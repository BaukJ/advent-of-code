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

            cell = { char:, connections: [], row:, column:, source_cells: {} }
            Pipes[char].each do |direction|
              case direction
              when :up then cell[:connections] << {direction:, cell: {row: row - 1, column: }, left_side: {row:, column: column - 1 }, right_side: {row:, column: column + 1}}
              when :down then cell[:connections] << {direction:, cell: {row: row + 1, column: }, left_side: {row:, column: column + 1}, right_side: {row:, column: column - 1 }}
              when :left then cell[:connections] << {direction:, cell: {row:, column: column - 1 }, left_side: {row: row + 1, column: }, right_side: {row: row - 1, column: }}
              when :right then cell[:connections] << {direction:, cell: {row:, column: column + 1}, left_side: {row: row - 1, column: }, right_side: {row: row + 1, column: }}
              else die "Invalid cell: #{char}"
              end
            end
            cell[:connections].select! do |c|
              c[:cell][:row] >= 0 && c[:cell][:column] >= 0
            end

            case char
            when "|" then 
              cell[:source_cells]["#{row-1}_#{column}"] = [
                [{row:, column: column + 1 }], #Left
                [{row:, column: column - 1 }],#Right
              ]
              cell[:source_cells]["#{row+1}_#{column}"] = cell[:source_cells]["#{row-1}_#{column}"].reverse
            when "-" then
              cell[:source_cells]["#{row}_#{column-1}"] = [
                [{row: row - 1, column: column }],
                [{row: row + 1, column: column }],
              ]
              cell[:source_cells]["#{row}_#{column+1}"] = cell[:source_cells]["#{row}_#{column-1}"].reverse
            when "L" then 
              cell[:source_cells]["#{row-1}_#{column}"] = [
                [],
                [{row: row + 1, column: column }, {row: row, column: column - 1}],
              ]
              cell[:source_cells]["#{row}_#{column+1}"] = cell[:source_cells]["#{row-1}_#{column}"].reverse
            when "J" then
              cell[:source_cells]["#{row-1}_#{column}"] = [
                [{row: row + 1, column: column }, {row: row, column: column + 1}],
                [],
              ]
              cell[:source_cells]["#{row}_#{column-1}"] = cell[:source_cells]["#{row-1}_#{column}"].reverse
            when "7" then
              cell[:source_cells]["#{row+1}_#{column}"] = [
                [],
                [{row: row - 1, column: column }, {row: row, column: column + 1}],
              ]
              cell[:source_cells]["#{row}_#{column-1}"] = cell[:source_cells]["#{row+1}_#{column}"].reverse
            when "F" then 
              cell[:source_cells]["#{row+1}_#{column}"] = [
                [{row: row - 1, column: column }, {row: row, column: column - 1}],
                [],
              ]
              cell[:source_cells]["#{row}_#{column+1}"] = cell[:source_cells]["#{row+1}_#{column}"].reverse
            when "S" then 
              cell[:source_cells]["#{row+1}_#{column}"] = [[],[]]
              cell[:source_cells]["#{row-1}_#{column}"] = [[],[]]
              cell[:source_cells]["#{row}_#{column+1}"] = [[],[]]
              cell[:source_cells]["#{row}_#{column-1}"] = [[],[]]
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
