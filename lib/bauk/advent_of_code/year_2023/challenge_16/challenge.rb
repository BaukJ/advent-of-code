# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge16
        # Challenge for 2023/16
        class Challenge < BaseChallenge
          Directions = {
            left: "<",
            right: ">",
            up: "^",
            down: "v"
          }.freeze
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @base_map = Map.from_lines @lines
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def add_path(row, column, direction)
            return unless @map.point_inside_map?({ row:, column: })

            while @base_map.cell(row, column).empty?
              return if @map.cell(row, column).include?(Directions[direction])

              @map.insert(row, column, Directions[direction])
              case direction
              when :right then column += 1
              when :left then column -= 1
              when :up then row -= 1
              when :down then row += 1
              else die "Invalid direction: #{direction}"
              end
              puts @map.to_s_with_border
              sleep 0.5
              return unless @map.point_inside_map?({ row:, column: })
            end
            @map.insert(row, column, "#")
            hit_cell = @base_map.cell(row, column)
            hit = hit_cell[0]
            case hit
            when "-"
              case direction
              when :up, :down
                add_path(row, column - 1, :left)
                add_path(row, column + 1, :right)
              when :left then add_path(row, column - 1, :left)
              when :right then add_path(row, column + 1, :right)
              end
            when "|"
              case direction
              when :left, :right
                add_path(row - 1, column, :up)
                add_path(row + 1, column, :down)
              when :up then add_path(row - 1, column, :up)
              when :down then add_path(row + 1, column, :down)
              end
            when "/"
              case direction
              when :up then add_path(row, column + 1, :right)
              when :down then add_path(row, column - 1, :left)
              when :left then add_path(row + 1, column, :down)
              when :right then add_path(row - 1, column, :up)
              end
            when "\\"
              case direction
              when :up then add_path(row, column - 1, :left)
              when :down then add_path(row, column + 1, :right)
              when :left then add_path(row - 1, column, :up)
              when :right then add_path(row + 1, column, :down)
              end
            else die "Invalid cell: #{hit_cell.inspect}"
            end
          end

          def get_energised_cells(row, column, direction)
            @map = Map.new @base_map.row_count, @base_map.column_count
            @map.allow_multiples = true
            add_path(row, column, direction)
            @map.cells.reject(&:empty?).length
          end

          def star_one
            @total = get_energised_cells(0, 0, :right)
            logger.warn "Star one answer: #{@total}"
          end

          def find_biggest(row, column, direction)
            energised = get_energised_cells(row, column, direction)
            @most_energised = energised if energised > @most_energised
          end

          def star_two
            @most_energised = 0
            (0..@base_map.column_max_index).each do |column|
              find_biggest(0, column, :down)
              find_biggest(@base_map.row_max_index, column, :up)
            end
            (0..@base_map.row_max_index).each do |row|
              find_biggest(row, 0, :right)
              find_biggest(row, @base_map.column_max_index, :left)
            end
            logger.warn "Star two answer: #{@most_energised}"
          end
        end
      end
    end
  end
end
