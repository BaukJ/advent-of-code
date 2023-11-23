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

          def unset(row, column)
            @map[row][column] = []
          end

          def to_s
            @map.map do |row|
              row.map { |column|
                if column.empty? then " "
                elsif column == ["o"] then "\e[48;5;10mo\e[0m"
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

        def initialize
          super
          @total_moves = 0
          @max_allowed_steps = 1000
          @base_map = Map.from_s(File.read(File.join(__dir__, "challenge_24.txt")))
          @base_map = Map.from_s(File.read(File.join(__dir__, "challenge_24_test.txt")))
          @maps = [@base_map]
          # @show_map = true
        end

        def run
          @start_time = Time.now
          generate_maps(@max_allowed_steps + 2) # Plus 2 just to be safe instead of putting in more complex logic
          turn(0, 1)
          logger.warn "SUCCESS. Finished parsing and found the quickest path: #{@steps}"
        end

        def generate_maps(count)
          logger.warn "Generating #{count} maps"
          (0..count).each do
            @maps << @maps[-1].update
          end
          logger.warn "Generating #{count} maps DONE"
        end

        def turn(row, column, steps = [], complete = 100)
          map = @maps[steps.length]
          if @show_map
            map.insert(row, column, "o")
            puts map
            sleep 0.1
            map.unset(row, column)
          end
          logger.debug { "[#{row},#{column}] steps=#{steps.length}: #{steps}" }
          
          if steps.length > @max_allowed_steps
            logger.info { "Hit the max allowe steps: #{steps.length}/#{@max_allowed_steps} #{complete}% complete" }
          elsif @step_count&.<= steps.length
            logger.info { "Too slow to beat current max: #{steps.length}/#{@step_count} #{complete}% complete" }
          elsif row == map.row_max_index && column == map.column_max_index - 1
            logger.warn "SUCCESS: steps=#{steps.length}  #{complete}% complete"
            @steps = steps
            @step_count = steps.length            
          elsif move(row, column, steps, complete)
            # Just a status update on moves
            @total_moves += 1
            if @total_moves % 1000000 == 0
              seconds_taken = (Time.now - @start_time).to_i
              minutes_taken = seconds_taken / 60
              logger.warn "Reached #{@total_moves} total moves in #{minutes_taken}m #{seconds_taken}s, completion is at #{complete}%"
            end
            exit if @total_moves > 5000000 # TODO: for testing performance
          else
            logger.info { "Dead end [#{row},#{column}] steps=#{steps.length}  #{complete}% complete" }
          end
        end
        
        def move(row, column, steps = [], complete = 100)
          map = @maps[steps.length + 1]
          if map.is_free?(row, column + 1) # right
            turn(row, column + 1, steps + [:r], complete * 0.2)
            moved = true
          end
          if map.is_free?(row + 1, column) # down
            turn(row + 1, column, steps + [:d], complete * 0.4)
            moved = true
          end
          if map.is_free?(row, column) # stand still / stop
            turn(row, column, steps + [:s], complete * 0.6)
            moved = true
          end
          if map.is_free?(row, column - 1) # left
            turn(row, column - 1, steps + [:l], complete * 0.8)
            moved = true
          end
          if map.is_free?(row - 1, column) # up
            turn(row - 1, column, steps + [:u], complete)
            moved = true
          end
          return moved
        end
      end
    end
  end
end
