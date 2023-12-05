# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge22
        # Challenge for 2022/22
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @route = @lines.pop
            die "Invalid input" unless @lines.pop.empty? && !@lines[-1].empty?
            @map = Map.from_lines @lines
            @row = 0
            @column = 0
            @facing_index = 0
            @facings = %w[R D L U]
            @facing_symbols = %w[> v < ^]
            fix_short_lines
            puts @map
          end

          def fix_short_lines
            @lines.each_with_index do |line, row|
              (line.length..@map.column_max_index).each do |column|
                @map.insert row, column, " "
              end
            end
          end

          def show_map
            return unless Opts.show_map

            @map.insert @row, @column, @facing_symbols[@facing_index]
            puts @map.to_s_with_border
            @map.remove @row, @column, @facing_symbols[@facing_index]
            sleep 0.1
          end

          def turn(direction)
            case direction
            when "R" then @facing_index += 1
            when "L" then @facing_index -= 1
            else die "Invalid direction to turn: #{direction}"
            end
            @facing_index = 0 if @facing_index >= @facings.length
            @facing_index = @facings.length - 1 if @facing_index.negative?
            show_map
          end

          def move(steps)
            (1..steps).each do |i|
              logger.debug { "Moving #{@facings[@facing_index]} from #{@row}/#{@column} (step #{i}/#{steps})"}
              set_succesful_cell if @map.empty? @row, @column
              case @facings[@facing_index]
              when "U" then move_up
              when "D" then move_down
              when "L" then move_left
              when "R" then move_right
              else die "Invalid direction: #{direction}"
              end
              show_map
            end
          end

          def move_back
            case @facings[@facing_index]
            when "U" then move_down
            when "D" then move_up
            when "L" then move_right
            when "R" then move_left
            else die "Invalid direction: #{direction}"
            end
          end

          def set_succesful_cell
            @last_row = @row
            @last_column = @column
          end

          def revert_to_succesful_move
            @row = @last_row
            @column = @last_column
          end

          def calculate_new_square
            logger.debug { "Calculating new sqaure from #{@row}/#{@column}"}
            if @box_shape
              move_around_square
            else
              @column = 0 if @column > @map.column_max_index
              @column = @map.column_max_index if @column.negative?
              @row = @map.row_max_index if @row.negative?
              @row = 0 if @row > @map.row_max_index
              # Find next free space
              move 1 if @map.cell(@row, @column).include? " "
            end
          end

          def move_around_square
            @mappings = {
              "3_0" => {
                source: {direction: "U", row: 3, column: 0},
                destination: {direction: "D", row: 0, column: 11},
              }
            }
            if Opts.file == "data.txt"
            else
              if @mappings["#{@row}_#{@column}"]
                mapping = @mappings["#{@row}_#{@column}"]
                die "Invalid direction (#{@facings[@facing_index]})" unless @facings[@facing_index] == mapping[:source][:direction]
                @facing_index = @facings.find_index mapping[:destination][:direction]
                @row = mapping[:destination][:row]
                @column = mapping[:destination][:column]
              elsif @row == -1
                @row = 4
                @column = 3 - (@column - 8)
                @facing_index = 1
              elsif @column == 12 && @row.between?(0, 3)
                @column = 15
                @row = 11 - @row
                @facing_index = 1
              elsif @column == 12 && @row.between?(4, 7)
                @column = 12 + 7 - @row
                @row = 8
                @facing_index = 2
              elsif @column == 16 && @row.between?(8, 11)
                @column = 11
                @row = 11 - @row
                @facing_index = 2
              elsif @row == 12 && @column.between?(12, 15)
                @row = 4 + 15 - @column
                @column = 0
                @facing_index = 2
              else
                die "Invalid position #{@row}/#{@column}"
              end
              check_move
            end
          end

          def move_right
            @column += 1
            check_move
          end

          def check_move
            # If new position is empty, success, if it's a wall, move back left to where you last were, otherwise we're in a void and we keep going
            if @row.negative? || @row > @map.row_max_index || @column.negative? || @column > @map.column_max_index || @map.cell(@row, @column).include?(" ")
              calculate_new_square
            elsif @map.cell(@row, @column).include?("#") then revert_to_succesful_move
            elsif @map.empty?(@row, @column) then set_succesful_cell
            else die "Invalid state"
            end
          end

          def move_left
            @column -= 1
            check_move
          end

          def move_up
            @row -= 1
            check_move
          end

          def move_down
            @row += 1
            check_move
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def do_route
            route = @route.clone
            until route.empty?
              if route.sub!(/^([A-Z])/, "")
                turn $1
              elsif route.sub!(/^([0-9]+)/, "")
                move $1.to_i
              else
                die "Invalid route: #{route}"
              end
            end
          end

          def star_one
            move_right # To make sure we start on the first valid square
            set_succesful_cell
            do_route
            logger.warn "Star one answer: #{((@row + 1) * 1000) + ((@column + 1) * 4) + @facing_index}"
          end

          def star_two
            @row = 0
            @column = 0
            move_right # To make sure we start on the first valid square
            set_succesful_cell
            @box_shape = true
            do_route
            logger.warn "Star two answer: #{((@row + 1) * 1000) + ((@column + 1) * 4) + @facing_index}"
          end
        end
      end
    end
  end
end
