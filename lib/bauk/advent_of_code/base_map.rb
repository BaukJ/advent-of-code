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

      # TODO: this logic
      def update
        new_map = generate_map
        @map.each_with_index do |row, row_index|
          row.each_with_index do |cell, column_index|
            if cell.is_a? Array
              cell.each do |item|
                update_item(row_index, column_index, item, new_map, map)
              end
            else
              update_item(row_index, column_index, cell, new_map, map)
            end
          end
        end
        new_map
      end

      def update!
        @map = update
      end

      def update_item(_row_index, _column_index, _cell, _new_map, _old_map)
        nil
      end

      def empty?(row_index, column_index)
        row_index < row_count && column_index < column_count && @map[row_index][column_index].empty?
      end
    end
  end
end
