require_relative "../challenge"

module Bauk
  module AdventOfCode
    module Year2022
      class Challenge24 < Challenge
        class Map < BaseClass
          attr_accessor :map
          attr_reader :row_max_index, :column_max_index, :row_count, :column_count

          def initialize(rows, columns)
            super()
            @row_count = rows
            @column_count = columns
            @row_max_index = rows - 1
            @column_max_index = columns - 1
            @map = []
            @map << (1..columns).map { "#" }
            (1..rows-2).each do
              @map << ["#", *(1..columns - 2).map { [] }, "#"]
            end
            @map << (1..columns).map { "#" }
            @map[0][1] = [] # Start
            @map[-1][-2] = [] # End
          end

          def insert(row, column, item)
            if item != "o"
              row = 1 if row == @row_max_index
              column = 1 if column == @column_max_index
              row = @row_max_index - 1 if row.zero?
              column = @column_max_index - 1 if column.zero?
            end
            @map[row][column] << item
          end

          def to_s
            @map.map do |row|
              row.map { |column|
                if column.empty? then " "
                elsif column.length > 1 then column.length
                else column[0]
                end
              }.join("")
            end.join("\n")
          end

          def self.from_s(string)
            items = string.split("\n").map do |row|
              row.split("").map do |i|
                if i == "." then []
                elsif i == "#" then i
                else [i]
                end
              end
            end
            map = Map.new(items.length, items[0].length)
            map.map = items
            map.validate_lengths
            map
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
            row >= 0 and column >= 0 and row <= @row_max_index and column <= @column_max_index and @map[row][column] == []
          end
        end

        def run
          map = Map.from_s(File.read(File.join(__dir__, "challenge_24.txt")))
          move(map, 0, 1)
        end

        def move(map, row, column, steps = [])
          puts map
          map = map.update
          if map.is_free?(row - 1, column)
            move(map, row - 1, column)
          elsif map.is_free?
          end
          puts map
        end
      end
    end
  end
end
