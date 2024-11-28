# frozen_string_literal: true

require_relative "base_class"
require_relative "utils"

module Bauk
  module AdventOfCode
    # Base class for all maps
    class BaseCharacter < BaseClass
      attr_accessor :row, :column, :map
      attr_reader :row_count, :column_count, :row_max_index, :column_max_index

      def initialize(name, row = 0, column = 0, map = nil)
        super()
        @name = name
        @row = row
        @column = column
        @map = map
      end

      def to_s
        "#{@name} [#{@row}/#{@column}]"
      end

      def cell
        @map.cell(@row, @column)
      end

      def move(row_delta, column_delta)
        @row += row_delta
        @column += column_delta
        cell # To ensure Map has this cell
        # while @row.negative?
        #   @map.insert_row 0
        #   @map.shift_characters(1, 0)
        # end
        # insert_row while @current_row > @row_max_index
        # while @current_column.negative?
        #   insert_column 0
        #   @map.shift_characters(1, 0)
        # end
        # insert_column while @current_column > @column_max_index
      end
    end
  end
end
