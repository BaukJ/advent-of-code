# frozen_string_literal: true

require_relative "../../base_challenge"

# S2 too hight: 962, 947
# S2 too low: 900
# S2 no: 939

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge17
        # Challenge for 2023/17
        class Challenge < BaseChallenge
          Sides = {
            left: %i[down up],
            right: %i[down up],
            up: %i[right left],
            down: %i[right left]
          }.freeze

          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            @max_steps_backwards = @map.row_count + @map.column_count
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def do_position(row, column, direction, straights, heat_loss, steps = [], steps_backwards = 0)
            return unless @map.point_inside_map?({ row:, column: })

            # puts "#{row}/#{column}) Direction: #{direction}, Straights: #{straights}, HL: #{heat_loss.inspect}"
            # puts @map.cell(row, column).inspect
            cell_heat_loss = @map.cell(row, column)
            heat_loss = heat_loss.dup + cell_heat_loss
            # been_key = "#{row}_#{column}_#{direction}"
            been_key = "#{row}_#{column}_#{direction}_#{straights}"
            do_sides = true
            step = { row:, column: }
            steps_backwards += 1 if %i[up left].include? direction

            if @min_heat_loss && heat_loss >= @min_heat_loss
              return
            elsif steps_backwards > @max_steps_backwards
              # This is a risky speed improvement
              return
            # elsif cell_heat_loss >= 8
            #   # This is another risky speed improvement as all the 9's are in the middle...
            #   return
            elsif row == @map.row_max_index && column == @map.column_max_index && straights >= @min_straights_before_turn
              @min_heat_loss ||= heat_loss
              @min_heat_loss = heat_loss if heat_loss < @min_heat_loss
              show_map(steps + [step]) if logger.info?
              logger.warn "FINISHED: #{heat_loss} (positions checked: #{@done_positions.underscore})"
              return
            elsif @min_heat_loss && (heat_loss + ((@map.row_max_index + @map.column_max_index - row - column) * 2)) >= @min_heat_loss
              return
            elsif @been[been_key] && heat_loss >= @been[been_key][:heat_loss]
              return
              # if straights == @been[been_key][:straights]
              #   return
              # elsif @been[been_key][:straights] >= @min_straights_before_turn
              #   # We've been here before, with more straights to do
              #   if straights > @been[been_key][:straights]
              #     # If we have less available moves than last time
              #     return
              #   elsif direction == :right && (column + @max_straights - @been[been_key][:straights]) > @map.column_max_index
              #     # If we have more than last time, but we're close to the right
              #     return
              #   elsif direction == :left && (column - @max_straights + @been[been_key][:straights]) < 0
              #     # If we have more than last time, but we're close to the left
              #     return
              #   elsif direction == :down && (row + @max_straights - @been[been_key][:straights]) > @map.row_max_index
              #     # If we have more than last time, but we're close to the bottom
              #     return
              #   elsif direction == :up && (row - @max_straights + @been[been_key][:straights]) < 0
              #     # If we have more than last time, but we're close to the top
              #     return
              #   end
              # end
            end

            @been[been_key] = { heat_loss:, straights: }
            @done_positions += 1
            show_map(steps + [step]) if Opts.show_map

            if %i[down right].include? direction
              # We're going the right way so do straight first
              if straights < @max_straights
                do_position(*calculate_row_colume(row, column, direction), direction, straights + 1, heat_loss, steps + [step], steps_backwards)
              end
              if do_sides && straights >= @min_straights_before_turn
                Sides[direction].each do |side|
                  do_position(*calculate_row_colume(row, column, side), side, 1, heat_loss, steps + [step], steps_backwards)
                end
              end
            else
              # We're going the wrong way, so try changing direction first
              if do_sides && straights >= @min_straights_before_turn
                Sides[direction].each do |side|
                  do_position(*calculate_row_colume(row, column, side), side, 1, heat_loss, steps + [step], steps_backwards)
                end
              end
              if straights < @max_straights
                do_position(*calculate_row_colume(row, column, direction), direction, straights + 1, heat_loss, steps + [step], steps_backwards)
              end
            end
          end

          def return_early?(row, column, direction, straights, heat_loss)
            been_key = "#{row}_#{column}_#{direction}"
            if @min_heat_loss && heat_loss >= @min_heat_loss
              return true
            elsif @been[been_key] && heat_loss >= @been[been_key][:heat_loss] && straights >= @been[been_key][:straights]
              return true
            elsif @min_heat_loss && (heat_loss - row - column + @map.row_max_index + @map.column_max_index) >= @min_heat_loss
              return true
            end

            @been[been_key] = { heat_loss:, straights: }
            false
          end

          def show_map(steps)
            map = @map.deep_clone
            steps.each do |step|
              map.replace_cell(step[:row], step[:column], " ")
            end
            map.replace_cell(steps[-1][:row], steps[-1][:column], "*")
            puts map.to_s_with_border
            sleep 0.2
          end

          def calculate_row_colume(row, column, direction, steps = 1)
            case direction
            when :up then [row - steps, column]
            when :down then [row + steps, column]
            when :left then [row, column - steps]
            when :right then [row, column + steps]
            else die "Direction: #{direction}"
            end
          end

          def star_one
            @min_heat_loss = Opts.min_heat_loss.zero? ? nil : Opts.min_heat_loss
            @been = {}
            @done_positions = 0
            @max_straights = 3
            @min_straights_before_turn = 0
            do_position(0, 0, :right, 0, -@map.cell(0, 0))
            do_position(0, 0, :down, 0, -@map.cell(0, 0))

            logger.warn "Star one answer: #{@min_heat_loss} (in #{@done_positions.underscore})"
          end

          def star_two
            @min_heat_loss = Opts.min_heat_loss.zero? ? nil : Opts.min_heat_loss
            @been = {}
            @done_positions = 0
            @max_straights = 10
            @min_straights_before_turn = 4
            do_position(0, 0, :down, 0, -@map.cell(0, 0))
            do_position(0, 0, :right, 0, -@map.cell(0, 0))

            logger.warn "Star two answer: #{@min_heat_loss} (in #{@done_positions.underscore})"
          end
        end
      end
    end
  end
end
