# frozen_string_literal: true

require_relative "base_class"

module Bauk
  module AdventOfCode
    # Base class for all maps
    class BaseMap < BaseClass
      attr_accessor :map
      attr_reader :row_count, :column_count, :row_max_index, :column_max_index

      def initialize(row_count, column_count)
        super()
        @row_count = row_count
        @column_count = column_count
        @row_max_index = row_count - 1
        @column_max_index = column_count - 1
        @allow_multiples = false
        @map = generate_map
      end

      def generate_map
        (0..@row_max_index).map do |row_index|
          generate_row(row_index)
        end
      end

      def generate_row(row_index)
        (0..@column_max_index).map do |column_index|
          generate_cell(row_index, column_index)
        end
      end

      def generate_cell(_row_index, _column_index)
        []
      end

      def to_s
        @map.map.with_index do |row, row_index|
          row.map.with_index do |column, column_index|
            if empty?(row_index, column_index) then " "
            elsif [["o"], "o"].include?(column) then "\e[48;5;10mo\e[0m"
            elsif !column.is_a? Array then column
            elsif column.length > 1 then column.length
            else
              column[0]
            end
          end.join
        end.join("\n")
      end

      def insert(row, column, item, allow_multiples: @allow_multiples)
        if @map[row][column].include?(item) && !allow_multiples
          die "Item '#{item}' already exists in cell #{row}/#{column} [#{@map[row][column].inspect}]"
        end
        @map[row][column] << item
      end

      def remove(row, column, item)
        @map[row][column].delete item
      end

      def reset_cell(row, column)
        @map[row][column] = generate_cell(row, column)
      end

      def row(index)
        @map[index]
      end

      def column(index)
        @map.map do |row|
          row[index]
        end
      end

      def cells
        @map.inject { |row, obj| row + obj }
      end

      def cell(row, column)
        @map[row][column]
      end

      def rows
        @map
      end

      def cells_with_indexes
        obj = []
        rows.each_with_index do |row, row_index|
          row.each_with_index do |cell, column_index|
            obj << [cell, row_index, column_index]
          end
        end
        obj
      end

      def update_map
        new_map = clone
        new_map.map = generate_map
        @map.each_with_index do |row, row_index|
          row.each_with_index do |cell, column_index|
            if cell.is_a? Array
              cell.each do |item|
                update_item(row_index, column_index, item, new_map)
              end
            else
              update_item(row_index, column_index, cell, new_map)
            end
          end
        end
        new_map
      end

      def update
        update_map
      end

      def update!
        @map = update_map.map
      end

      def update_item(_row_index, _column_index, _item, _new_map)
        nil
      end

      def empty?(row_index, column_index)
        row_index < row_count && column_index < column_count && @map[row_index][column_index].empty?
      end

      def adjacent_4_cells(row_index, column_index)
        adjacent = []
        adjacent << cell(row_index, column_index + 1) unless column_index >= @column_max_index
        adjacent << cell(row_index, column_index - 1) unless column_index <= 0
        adjacent << cell(row_index + 1, column_index) unless row_index >= @row_max_index
        adjacent << cell(row_index - 1, column_index) unless row_index <= 0
        adjacent
      end

      def to_s_with_border
        [
          "-" * (@column_count + 2),
          "|" + to_s.split("\n").join("|\n|") + "|",
          "-" * (@column_count + 2),
        ].join("\n")
      end

      def insert_row(index = -1)
        @map.insert(index, generate_row(index))
        @row_count += 1
        @row_max_index += 1
      end

      def insert_column(index = -1)
        rows.each_with_index do |row, row_index|
          row.insert(index, generate_cell(row_index, index))
        end
        @column_count += 1
        @column_max_index += 1
      end

      def delete_row(index = -1)
        @map.delete_at(index)
        @row_count -= 1
        @row_max_index -= 1
      end

      def delete_column(index = -1)
        rows.each_with_index do |row, row_index|
          row.delete_at(index)
        end
        @column_count -= 1
        @column_max_index -= 1
      end
    end
  end
end
