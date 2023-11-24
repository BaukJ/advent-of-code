# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge24
        class Map < BaseMap
          def initialize(rows, columns)
            super(rows, columns)
            @booleanized = false
            @map[0][1] = [] # Start
            @map[-1][-2] = [] # End
          end

          def generate_cell(row, column)
            if row.zero? || row == row_max_index then "#"
            elsif column.zero? || column == column_max_index then "#"
            else []
            end
          end

          def insert(row, column, item)
            if item != "o"
              row = 1 if row >= @row_max_index
              column = 1 if column >= @column_max_index
              row = @row_max_index - 1 if row.zero?
              column = @column_max_index - 1 if column.zero?
            else
              raise "Attempting to put person in non-free spot!" unless is_free? row, column
            end
            if @booleanized
              @map[row][column] = item
            else
              @map[row][column] << item
            end
          end

          def unset(row, column)
            @map[row][column] = @booleanized ? true : []
          end

          def to_s
            @map.map do |row|
              row.map do |column|
                if column == true then " "
                elsif column == false then "X"
                elsif column.empty? then " "
                elsif [["o"], "o"].include?(column) then "\e[48;5;10mo\e[0m"
                elsif column.length > 1 then column.length
                else
                  column[0]
                end
              end.join("")
            end.join("\n")
          end

          def self.from_s(string)
            items = string.split("\n").map do |row|
              row.split("").map do |i|
                if i == "." then []
                elsif i == "#" then i
                else
                  [i]
                end
              end
            end
            new_map = Map.new(items.length, items[0].length)
            new_map.map = items
            new_map.validate_lengths
            new_map
          end

          def validate_lengths
            @map.each do |row|
              logger.debug row.inspect
              die "Row length mismatch (should be #{column_count}): #{row}" if row.length != column_count
            end
          end

          def update
            new_map = Map.new(@row_count, @column_count)
            @map.each_with_index do |row, row_count|
              row.each_with_index do |column, column_count|
                next if column == "#"

                column.each do |item|
                  if item == "v" then new_map.insert(row_count + 1, column_count, item)
                  elsif item == "^" then new_map.insert(row_count - 1, column_count, item)
                  elsif item == ">" then new_map.insert(row_count, column_count + 1, item)
                  elsif item == "<" then new_map.insert(row_count, column_count - 1, item)
                  elsif item != "o" then raise "Invalid item found in table: #{item}"
                  end
                end
              end
            end
            new_map
          end

          def is_free?(row, column)
            return @map[row][column] if @booleanized
            empty? row, column
          end

          # This makes the map almost unreadable, but speeds up the is_free check
          # It changes each item to just a true or false value, true if the space is free
          def booleanize!
            @booleanized = true
            @map.map! do |row|
              row.map do |column|
                column.is_a?(Array) && (column.empty? || column == ["o"])
              end
            end
          end
        end
      end
    end
  end
end
