# frozen_string_literal: true

require_relative "../../base_challenge"

# S2 too hight: 962

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
            down: %i[right left],
          }.freeze
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def do_position(row, column, direction, straights, heat_loss)
            return unless @map.point_inside_map?({ row:, column: })

            @done_positions += 1
            # puts "#{row}/#{column}) Direction: #{direction}, Straights: #{straights}, HL: #{heat_loss.inspect}"
            # puts @map.cell(row, column).inspect
            heat_loss = heat_loss.dup + @map.cell(row, column)
            # show_map(row, column, heat_loss)
            been_key = "#{row}_#{column}_#{direction}"
            do_sides = true
            
            if @min_heat_loss && heat_loss >= @min_heat_loss
              return
            elsif row == @map.row_max_index && column == @map.column_max_index && straights >= @min_straights_before_turn
              logger.info "FINISHED: #{heat_loss} (positions checked: #{@done_positions.underscore})"
              @min_heat_loss ||= heat_loss
              @min_heat_loss = heat_loss if heat_loss < @min_heat_loss
              return
            elsif @been[been_key] && heat_loss >= @been[been_key][:heat_loss]
              if straights >= @been[been_key][:straights]
                return # This logic isn't perfect for star two, as it could be beneficial to be further along a straight
              else
                do_sides = false
              end
            elsif @min_heat_loss && (heat_loss - row - column + @map.row_max_index + @map.column_max_index) >= @min_heat_loss
              return
            end
            @been[been_key] = { heat_loss:, straights:}
            
            
            # puts straights
            Sides[direction].each do |side|
              do_position(*calculate_row_colume(row, column, side), side, 1, heat_loss)
            end if do_sides && straights >= @min_straights_before_turn
            if straights < @max_straights
              do_position(*calculate_row_colume(row, column, direction), direction, straights + 1, heat_loss)
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
            @been[been_key] = { heat_loss:, straights:}
            false
          end

          def show_map(row, column, heat_loss)
            old = @map.cell(row, column)
            @map.replace_cell row, column, " "
            puts "HL: #{heat_loss}"
            puts @map.to_s_with_border
            @map.replace_cell row, column, old
            sleep 1
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
            @min_heat_loss = Opts.min_heat_loss == 0 ? nil : Opts.min_heat_loss
            @been = {}
            @done_positions = 0
            @max_straights = 3
            @min_straights_before_turn = 0
            do_position(0, 0, :right, 0, -@map.cell(0, 0))

            logger.warn "Star one answer: #{@min_heat_loss} (in #{@done_positions.underscore})"
          end

          def star_two
            @min_heat_loss = Opts.min_heat_loss == 0 ? nil : Opts.min_heat_loss
            @been = {}
            @done_positions = 0
            @max_straights = 10
            @min_straights_before_turn = 4
            do_position(0, 0, :right, 0, -@map.cell(0, 0))

            logger.warn "Star one answer: #{@min_heat_loss} (in #{@done_positions.underscore})"
          end
        end
      end
    end
  end
end
