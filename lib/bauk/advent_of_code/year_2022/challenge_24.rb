require_relative "../challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge24
        class Map < BaseClass
          attr_accessor :map
          attr_reader :row_max_index, :column_max_index, :row_count, :column_count

          def initialize(rows, columns)
            super()
            @booleanized = false
            @row_count = rows
            @column_count = columns
            @row_max_index = rows - 1
            @column_max_index = columns - 1
            @map = []
            @map << (1..columns).map { "#" }
            (1..rows - 2).each do
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
                elsif column == ["o"] || column == "o" then "\e[48;5;10mo\e[0m"
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
            return @map[row][column] if @booleanized

            row >= 0 and column >= 0 and row <= @row_max_index and column <= @column_max_index and @map[row][column] == []
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

        class Runner < Challenge
          def initialize
            super
            initialize_counters
            @max_allowed_steps = 50
            @max_possible_steps = 5**@max_allowed_steps # Theoretical max steps before the program finishes
            @base_map = Map.from_s(File.read(File.join(__dir__, "challenge_24.txt")))
            @base_map = Map.from_s(File.read(File.join(__dir__, "challenge_24_test_a.txt")))
            @base_map = Map.from_s(File.read(File.join(__dir__, "challenge_24_test_c.txt")))
            @maps = [@base_map]
            # @show_map = true
          end

          def initialize_counters
            @total_moves = 0
            @terminated_dead_ends = 0
            @terminated_too_long = 0
            @active_paths = 0
          end

          def run
            generate_maps(@max_allowed_steps + 2) # Plus 2 just to be safe instead of putting in more complex logic
            @start_time = Time.now
            logger.warn("Starting run")
            turn(0, 1)
            logger.warn "Finished in #{time_taken}"
            if @steps
              logger.warn "SUCCESS. Finished parsing and found the quickest path in #{@steps.length} steps: #{@steps}"
            else
              logger.warn "FAILURE: Could not find a route in only #{@max_allowed_steps} steps (#{@terminated_dead_ends} dead ends and #{@terminated_too_long} too long)"
            end
          end

          def generate_maps(count)
            logger.warn "Generating #{count} maps"
            (0..count).each do
              @maps << @maps[-1].update
            end
            @maps.each { |map| map.booleanize! }
            # [@maps, @start_time].each { |obj| Ractor.make_shareable(obj) }
            logger.warn "Generating #{count} maps DONE"
          end

          def turn(row, column, steps = [], step_count = 0)
            map = @maps[step_count]
            # if @show_map
            #   puts "TURN: #{steps.length}"
            #   map.insert(row, column, "o")
            #   puts map
            #   sleep 0.1
            #   map.unset(row, column)
            # end
            # logger.debug { "[#{row},#{column}] steps=#{steps.length}: #{steps}" }

            if give_up?(map, row, column, steps, step_count)
              nil
            elsif move(row, column, steps, step_count)
              # Just a status update on moves
              # @total_moves += 1
              # if @total_moves % 10000000 == 0
              # if @total_moves % 1_000_000 == 0
              #   logger.warn "Reached #{@total_moves} total moves in #{time_taken} completion will be more than #{100 * @total_moves.to_f / @max_possible_steps}%"
              # end
              # exit if @total_moves > 3000000 # TODO: for testing performance
            else
              # logger.info { "Dead end [#{row},#{column}] steps=#{steps.length}" }
              # @terminated_dead_ends += 1
            end
          end

          def time_taken
            seconds_taken = (Time.now - @start_time).to_i
            minutes_taken = seconds_taken / 60
            seconds_taken %= 60
            "#{minutes_taken}m #{seconds_taken}s"
          end

          def finished?(map, row, column, steps, step_count)
            if row == map.row_max_index && column == map.column_max_index - 1
              return false if @step_count&.<= step_count # Ignore finished paths that are no shorter

              @steps = steps
              @step_count = steps.length
              return true
            end
            false
          end

          def give_up?(map, row, column, steps, step_count)
            max_steps = @step_count || @max_allowed_steps # Use the lowest found path or max steps
            if finished?(map, row, column, steps, step_count)
              logger.warn "SUCCESS: steps=#{step_count} in #{time_taken}"
            elsif step_count >= max_steps
              # logger.info do
              #   "Too many steps taken: #{step_count} [max allowed: #{@max_allowed_steps}, shortest found path: #{@steps_count}]"
              # end
              # @terminated_too_long += 1
            elsif (max_steps - step_count) < (map.row_max_index - row) + (map.column_max_index - 1 - column) # Last row, second to last column
              # logger.info do
              #   "Would hit the max allowed steps: [max allowed: #{@max_allowed_steps}, shortest found path: #{@steps_count}]"
              # end
              # @terminated_too_long += 1
            else
              return false
            end
            true
          end

          def move(row, column, steps, step_count)
            new_step_count = step_count + 1
            map = @maps[new_step_count]
            moved = false
            if map.is_free?(row, column + 1) # right
              turn(row, column + 1, steps + [:r], new_step_count)
              moved = true
            end
            if map.is_free?(row + 1, column) # down
              turn(row + 1, column, steps + [:d], new_step_count)
              moved = true
            end
            if map.is_free?(row, column) # stand still / stop
              turn(row, column, steps + [:s], new_step_count)
              moved = true
            end
            if map.is_free?(row, column - 1) # left
              turn(row, column - 1, steps + [:l], new_step_count)
              moved = true
            end
            if map.is_free?(row - 1, column) # up
              turn(row - 1, column, steps + [:u], new_step_count)
              moved = true
            end
            moved
          end
        end
      end
    end
  end
end
