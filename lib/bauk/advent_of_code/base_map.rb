# frozen_string_literal: true

require_relative "base_class"
require_relative "utils"
require_relative "base_character"

module Bauk
  module AdventOfCode
    # Base class for all maps
    class BaseMap < BaseClass # rubocop:disable Metrics/ClassLength
      attr_accessor :map, :allow_multiples, :infinite, :characters, :strict_indexes
      attr_reader :row_count, :column_count, :row_max_index, :column_max_index

      def self.from_file(file)
        from_lines File.readlines(file, chomp: true)
      end

      def self.from_lines(lines)
        map = new lines.length, lines[0].length
        lines.each_with_index do |line, row|
          line.chars.each_with_index do |char, column|
            map.replace_cell row, column, cell_from_char(char, row, column)
          end
        end
        map
      end

      def self.from_cell_arrays(arrays)
        map = new arrays.length, arrays[0].length
        arrays.each_with_index do |array, row|
          array.each_with_index do |cell, column|
            map.replace_cell row, column, cell
          end
        end
        map
      end

      def self.cell_from_char(char, _row, _column)
        case char
        when "." then []
        else [char]
        end
      end

      def normalise_indexes(row_index, column_index)
        raise Error, "Row index too high (#{row_index}/#{@row_max_index})" if row_index > @row_max_index
        raise Error, "Column index too high (#{column_index}/#{@column_max_index})" if column_index > @column_max_index
        raise Error, "Row index too low (#{row_index}/-#{@row_max_index})" if row_index < @row_max_index
        raise Error, "Column index too low (#{column_index}/-#{@column_max_index})" if column_index < -@column_max_index

        [row_index, column_index]
      end

      def initialize(row_count, column_count)
        super()
        @row_count = row_count
        @column_count = column_count
        @row_max_index = row_count - 1
        @column_max_index = column_count - 1
        @allow_multiples = false
        @infinite = false
        @characters = {}
        @strict_indexes = true
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
          row.map.with_index do |cell, column_index|
            cell_to_s(cell, row_index, column_index)
          end.join
        end.join("\n")
      end

      def cell_to_s(cell, row_index, column_index)
        return cell unless cell.is_a? Array

        if empty?(row_index, column_index) then "."
        elsif [["o"], "o"].include?(cell) then "\e[48;5;10mo\e[0m"
        elsif !cell.is_a? Array then cell
        elsif cell.length > 1 then cell.length
        else
          cell[0]
        end
      end

      def insert(row, column, item, allow_multiples: @allow_multiples)
        die "Item '#{item}' already exists in cell #{row}/#{column} [#{@map[row][column].inspect}]" if @map[row][column].include?(item) && !allow_multiples
        @map[row][column] << item
      end

      def remove(row, column, item)
        @map[row][column].delete item
      end

      def reset_cell(row, column)
        @map[row][column] = generate_cell(row, column)
      end

      def replace_cell(row, column, cell)
        @map[row][column] = cell
      end

      def move_characters(row_delta, column_delta)
        @characters.each do |_name, character|
          character.move row_delta, column_delta
        end
      end

      def shift_characters(row_delta, column_delta)
        @characters.each do |_name, character|
          character.row += row_delta
          character.column += column_delta
        end
      end

      def add_character(name, row=0, column=0)
        @characters[name] = BaseCharacter.new name, row, column, self
      end

      def row_check(index)
        min = @strict_indexes ? 0 : -@row_max_index
        if index < min
          raise Error, "Requested invalid row index (#{index} < #{min})" unless @infinite

          shift = min - index
          shift_characters shift, 0
          shift.times { insert_row 0 }
        end
        if index > @row_max_index
          raise Error, "Requested invalid row index (#{index} > #{@row_max_index})" unless @infinite

          insert_row while index > @row_max_index
        end
      end

      def row(index)
        row_check index
        @map[index]
      end

      def column_check(index)
        min = @strict_indexes ? 0 : -@column_max_index
        if index < min
          raise Error, "Requested invalid column index (#{index} < #{-@column_max_index})" unless @infinite

          shift = min - index
          shift_characters 0, shift
          shift.times { insert_column 0 }
        end
        if index > @column_max_index
          raise Error, "Requested invalid column index (#{index} > #{@column_max_index})" unless @infinite

          insert_column while index > @column_max_index
        end
      end

      def column(index)
        column_check index
        @map.map do |row|
          row[index]
        end
      end

      def cells
        @map.inject { |row, obj| row + obj }
      end

      def cells_with_row_column
        ret = []
        @map.each_with_index do |row, row_index|
          row.each_with_index do |char, column_index|
            ret << [char, row_index, column_index]
          end
        end
        ret
      end

      def line_of_cells(points)
        [cell_from_hash(points[0])] + path_to_cells(points)
      end

      def point_inside_map?(point)
        point[:row] >= 0 && point[:row] < @row_count && point[:column] >= 0 && point[:column] < @column_count
      end

      # line line_of_cells, but omits your starting point
      def path_to_cells(points)
        path = []
        (1...points.length).each do |i|
          point = points[i]
          previous_point = points[i - 1]

          die { "Invalid point #{point}" } unless point_inside_map? point
          die { "Invalid point #{previous_point}" } unless point_inside_map? previous_point

          if point[:row] == previous_point[:row]
            Utils.inclusive_bidirectional_range(previous_point[:column], point[:column])[1..].each do |column|
              path << cell(point[:row], column)
            end
          elsif point[:column] == previous_point[:column]
            Utils.inclusive_bidirectional_range(previous_point[:row], point[:row])[1..].each do |row|
              path << cell(row, point[:column])
            end
          else
            die "Cannot generate line of cells not in a straight line"
          end
        end
        path
      end

      def cell(row, column)
        row_check row
        column_check column
        @map[row][column]
      end

      def cell_from_hash(hash)
        cell(hash[:row], hash[:column])
      end

      def rows
        @map
      end

      def columns
        (0..@column_max_index).map { |i| column(i) }
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

      def deep_clone
        new_map = clone
        new_map.map = @map.deep_clone
        new_map
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

      def adjacent_4_cells_with_row_column(row_index, column_index)
        adjacent = []
        adjacent << cell_with_row_column(row_index, column_index + 1) unless column_index >= @column_max_index
        adjacent << cell_with_row_column(row_index, column_index - 1) unless column_index <= 0
        adjacent << cell_with_row_column(row_index + 1, column_index) unless row_index >= @row_max_index
        adjacent << cell_with_row_column(row_index - 1, column_index) unless row_index <= 0
        adjacent
      end

      def cell_with_row_column(row_index, column_index)
        [cell(row_index, column_index), row_index, column_index]
      end

      def adjacent_8_cells_with_row_column(row_index, column_index)
        adjacent = adjacent_4_cells_with_row_column(row_index, column_index)
        adjacent << cell_with_row_column(row_index + 1, column_index + 1) unless row_index >= @row_max_index || column_index >= @column_max_index
        adjacent << cell_with_row_column(row_index + 1, column_index - 1) unless row_index >= @row_max_index || column_index <= 0
        adjacent << cell_with_row_column(row_index - 1, column_index + 1) unless row_index <= 0 || column_index >= @column_max_index
        adjacent << cell_with_row_column(row_index - 1, column_index - 1) unless row_index <= 0 || column_index <= 0
        adjacent
      end

      def to_s_with_border
        [
          "-" * (@column_count + 2),
          "|#{to_s.split("\n").join("|\n|")}|",
          "-" * (@column_count + 2)
        ].join("\n")
      end

      def insert_row(index = -1, new_row = nil)
        new_row ||= generate_row(index)
        @map.insert(index, new_row)
        @row_count += 1
        @row_max_index += 1
      end

      def insert_column(index = -1, new_column = nil)
        rows.each_with_index do |row, row_index|
          new_cell = new_column ? new_column[row_index] : generate_cell(row_index, index)
          row.insert(index, new_cell)
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
        rows.each_with_index do |row, _row_index|
          row.delete_at(index)
        end
        @column_count -= 1
        @column_max_index -= 1
      end
    end
  end
end
