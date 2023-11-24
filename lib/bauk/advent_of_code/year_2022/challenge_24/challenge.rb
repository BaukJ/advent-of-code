# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge24
        class Challenge < BaseChallenge
          def initialize
            super
            initialize_counters
            @base_map = Map.from_s(File.read(File.join(__dir__, Opts.map_file)))
            @maps = [@base_map]
          end

          def initialize_counters
            @total_moves = 0
            @terminated_dead_ends = 0
            @terminated_too_long = 0
            @active_paths = 0
            @go_back = false
          end

          def run
            generate_maps(Opts.max_steps + 2) # Plus 2 just to be safe instead of putting in more complex logic
            @start_time = Time.now
            logger.warn("Starting run")
            turn(0, 1)
            logger.warn("Heading back now")
            @go_back = true
            @moves = {}
            @step_count = nil
            steps = @steps
            @steps = nil
            turn(@maps[0].row_max_index, @maps[0].column_max_index - 1, steps, steps.length)
            logger.warn("Heading there again")
            @go_back = false
            @moves = {}
            @step_count = nil
            steps = @steps
            @steps = nil
            turn(0, 1, steps, steps.length)
            # rounds()
            logger.warn "Finished in #{time_taken}"
            if @steps
              logger.warn "SUCCESS. Finished parsing and found the quickest path in #{@steps.length} steps: #{@steps}"
              show_path(@steps) if Opts.show_map
              logger.warn "SUCCESS. Finished parsing and found the quickest path in #{@steps.length} steps: #{@steps}"
            else
              logger.warn "FAILURE: Could not find a route in only #{Opts.max_steps} steps (#{@terminated_dead_ends} dead ends and #{@terminated_too_long} too long)"
            end
          end

          def generate_maps(count)
            logger.warn "Generating #{count} maps"
            (0..count).each do
              @maps << @maps[-1].update
            end
            @maps.each(&:booleanize!) if Opts.booleanize
            logger.warn "Generating #{count} maps DONE"
          end

          def show_path(path)
            row = 0
            column = 1
            path.each_with_index do |path, index|
              map = @maps[index]
              case path
              when :u then row -= 1
              when :d then row += 1
              when :l then column -= 1
              when :r then column += 1
              end
              map.insert(row, column, "o")
              puts map
              sleep Opts.show_map_sleep
            end
          end

          def rounds
            paths = [{ row: 0, column: 1, steps: [] }]
            (0..Opts.max_steps).each do |itteration|
              logger.warn "Doing itteration #{itteration} (#{paths.length} paths) in #{time_taken}"
              paths = prune_paths paths
              paths = round(paths, itteration)
              return if paths.empty?
            end
          end

          # Removed any paths that end you up in the same place, assuming they all have the same length
          def prune_paths(paths)
            pruned_paths = {}
            paths.each do |path|
              if pruned_paths["#{path[:row]}_#{path[:column]}"]
                logger.debug "Pruned the following: #{path} with #{pruned_paths["#{path[:row]}_#{path[:column]}"]}"
              end
              pruned_paths["#{path[:row]}_#{path[:column]}"] = path
            end
            pruned_paths.values
          end

          def round(paths, itteration)
            map = @maps[itteration]
            mew_map = @maps[itteration]
            new_paths = []
            paths.each do |path|
              if Opts.show_map
                puts "Itteration: #{itteration}"
                map.insert(path[:row], path[:column], "o")
                puts map
                sleep Opts.show_map_sleep
                map.unset(path[:row], path[:column])
              end
              if finished?(map, path[:row], path[:column], path[:steps], itteration)
                logger.warn "SUCCESS: steps=#{itteration} in #{time_taken}"
                return []
              else
                if mew_map.is_free?(path[:row], path[:column] + 1) # right
                  new_paths << { row: path[:row], column: path[:column] + 1, steps: path[:steps] + [:r] }
                end
                if mew_map.is_free?(path[:row] + 1, path[:column]) # down
                  new_paths << { row: path[:row] + 1, column: path[:column], steps: path[:steps] + [:d] }
                end
                if mew_map.is_free?(path[:row], path[:column]) # stand still / stop
                  new_paths << { row: path[:row], column: path[:column], steps: path[:steps] + [:s] }
                end
                if mew_map.is_free?(path[:row], path[:column] - 1) # left
                  new_paths << { row: path[:row], column: path[:column] - 1, steps: path[:steps] + [:l] }
                end
                if mew_map.is_free?(path[:row] - 1, path[:column]) # up
                  new_paths << { row: path[:row] - 1, column: path[:column], steps: path[:steps] + [:u] }
                end
              end
            end
            new_paths
          end

          def turn(row, column, steps = [], step_count = 0)
            map = @maps[step_count]
            if Opts.show_map
              puts "TURN: #{steps.length}"
              map.insert(row, column, "o")
              puts map
              sleep Opts.show_map_sleep
              map.unset(row, column)
            end
            logger.debug { "[#{row},#{column}] steps=#{steps.length}: #{steps}" }

            if finished?(map, row, column, steps, step_count)
              logger.warn "SUCCESS: steps=#{step_count} in #{time_taken}"
            elsif give_up?(map, row, column, steps, step_count)
              nil
            elsif move(row, column, steps, step_count)
              # Just a status update on moves
              @total_moves += 1
              logger.warn "Reached #{@total_moves} total moves in #{time_taken}" if (@total_moves % 10_000_000).zero?
            else
              logger.info { "Dead end [#{row},#{column}] steps=#{steps.length}" }
              @terminated_dead_ends += 1
            end
          end

          def time_taken
            seconds_taken = (Time.now - @start_time).to_i
            minutes_taken = seconds_taken / 60
            seconds_taken %= 60
            "#{minutes_taken}m #{seconds_taken}s"
          end

          def finished?(map, row, column, steps, step_count)
            return false if @step_count&.<= step_count # Ignore finished paths that are no shorter

            if (!@go_back && row == map.row_max_index && column == map.column_max_index - 1) || (@go_back && row.zero? && column == 1)
              @steps = steps
              @step_count = steps.length
              return true
            end
            false
          end

          def give_up?(_map, row, column, _steps, step_count)
            max_steps = @step_count || Opts.max_steps # Use the lowest found path or max steps
            @moves ||= {}
            move_key = "#{step_count}_#{row}_#{column}"
            if step_count >= max_steps
              logger.info do
                "Too many steps taken: #{step_count} [max allowed: #{max_steps}, shortest found path: #{@steps_count}]"
              end
              @terminated_too_long += 1
            # elsif (max_steps - step_count) < (map.row_max_index - row) + (map.column_max_index - 1 - column) # Last row, second to last column
            #   logger.info do
            #     "Would hit the max allowed steps: [max allowed: #{max_steps}, shortest found path: #{@steps_count}]"
            #   end
            #   @terminated_too_long += 1
            elsif @moves[move_key]
              logger.info do
                "Hit an already taken path: #{move_key}"
              end
            else
              @moves[move_key] = true
              return false
            end
            true
          end

          def generate_movements(row, column)
            m = {
              r: {
                step: :r,
                row: row,
                column: column + 1
              },
              l: {
                step: :l,
                row: row,
                column: column - 1
              },
              u: {
                step: :u,
                row: row - 1,
                column: column
              },
              d: {
                step: :d,
                row: row + 1,
                column: column
              },
              s: {
                step: :s,
                row: row,
                column: column
              }
            }
            if @go_back
              %i[l u s r d].map { |direction| m[direction] }
            else
              %i[r d s l u].map { |direction| m[direction] }
            end
          end

          def move(row, column, steps, step_count)
            new_step_count = step_count + 1
            map = @maps[new_step_count]
            moved = false
            generate_movements(row, column).each do |move|
              if map.is_free?(move[:row], move[:column])
                turn(move[:row], move[:column], steps + [move[:step]], new_step_count)
                moved = true
              end
            end
            moved
          end
        end
      end
    end
  end
end
