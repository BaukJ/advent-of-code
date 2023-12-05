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
            @map.reset_cell @row, @column
            sleep 0.5
          end

          def move(steps)
            (0...steps).each do
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

          def move_right
            @column += 1
            @column = 0 if @column > @map.column_max_index
            # If new position is empty, success, if it's a wall, move back left to where you last were, otherwise we're in a void and we keep going
            if @map.empty?(@row, @column) then nil
            elsif @map.cell(@row, @column).include?("#") then move_left
            else
              move_right
            end
          end

          def move_left
            @column -= 1
            @column = @map.column_max_index if @column.negative?
            # If new position is empty, success, if it's a wall, move back left to where you last were, otherwise we're in a void and we keep going
            if @map.empty?(@row, @column) then nil
            elsif @map.cell(@row, @column).include?("#") then move_right
            else
              move_left
            end
          end

          def move_up
            @row -= 1
            @row = @map.row_max_index if @row.negative?
            # If new position is empty, success, if it's a wall, move back left to where you last were, otherwise we're in a void and we keep going
            if @map.empty?(@row, @column) then nil
            elsif @map.cell(@row, @column).include?("#") then move_down
            else
              move_up
            end
          end

          def move_down
            @row += 1
            @row = 0 if @row > @map.row_max_index
            # If new position is empty, success, if it's a wall, move back left to where you last were, otherwise we're in a void and we keep going
            if @map.empty?(@row, @column) then nil
            elsif @map.cell(@row, @column).include?("#") then move_up
            else
              move_down
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            move_right # To make sure we start on the first valid square
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
            logger.warn "Star one answer: #{((@row + 1) * 1000) + ((@column + 1) * 4) + @facing_index}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
