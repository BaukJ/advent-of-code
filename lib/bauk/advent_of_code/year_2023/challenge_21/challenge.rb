# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge21
        # Challenge for 2023/21
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            start = @map.cells_with_row_column.select { |cell,r,c| cell.include? "S" }.last
            @row = start[1]
            @column = start[2]
            @map.remove @row, @column, "S"
            @original_map = @map.deep_clone
            puts @map
            add_map_right
            puts @map
          end

          def steps(count)
            positions = [{row: @row, column: @column}]
            count.times do
              # show_positions(positions)
              new_positions = []
              positions.each do |position|
                @map.adjacent_4_cells_with_row_column(position[:row], position[:column]).each do |cell, row, column|
                  new_positions << {row:, column:} if cell.empty?
                end
              end
              positions = new_positions.uniq
              check_map_size(positions)
            end
            positions.length
          end

          def steps2(count) # rubocop:disable Metrics/AbcSize
            positions = [{row: @row, column: @column}]
            @map = @original_map.deep_clone
            @map.insert @row, @column, :E
            even = true
            count.times do
              even = !even
              show_positions([])
              new_positions = []
              positions.each do |position|
                @map.adjacent_4_cells_with_row_column(position[:row], position[:column]).each do |cell, row, column|
                  if cell.empty?
                    new_positions << {row:, column:}
                    @map.insert row, column, even ? :E : :e
                  end
                end
              end
              positions = new_positions.uniq
              check_map_size(positions)
            end
            @map.cells.select { |cell| cell.include? (even ? :E : :e) }.length
          end

          def check_map_size(positions) # rubocop:disable Metrics/AbcSize
            logger.info { "Check map size start" }
            positions.each do |position|
              if position[:row] == @map.row_max_index
                add_map_down
              elsif position[:column] == @map.column_max_index
                add_map_right
              elsif position[:row] == 0
                positions.each do |pos|
                  pos[:row] += @map.row_count
                end
                add_map_up
                check_map_size(positions)
                break
              elsif position[:column] == 0
                positions.each do |pos|
                  pos[:column] += @map.column_count
                end
                add_map_left
                check_map_size(positions)
                break
              end
            end
            logger.info { "Check map size end" }
          end

          def add_map_right
            @map.deep_clone.columns.each do |column|
              column.each { |c| c.delete(:e); c.delete(:E) }
              @map.insert_column(-1, column)
            end
          end

          def add_map_left
            @map.deep_clone.columns.reverse.each do |column|
              column.each { |c| c.delete(:e); c.delete(:E) }
              @map.insert_column(0, column)
            end
          end

          def add_map_down
            @map.deep_clone.rows.each do |row|
              row.each { |c| c.delete(:e); c.delete(:E) }
              @map.insert_row(-1, row)
            end
          end

          def add_map_up
            @map.deep_clone.rows.reverse.each do |row|
              row.each { |c| c.delete(:e); c.delete(:E) }
              @map.insert_row(0, row)
            end
          end

          def show_positions(positions)
            return
            map = @map.deep_clone
            positions.each do |position|
              map.insert position[:row], position[:column], "O"
            end
            puts map.to_s_with_border
            sleep 0.5
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            # [6, 10, 50, 100, 500, 5000].each do |n|
            [6, 10, 50, 100, 500, 5000].each do |n|
              logger.warn "Test: #{n} -> #{steps2(n)}"
            end
            # logger.warn "Star one answer: 64 -> #{steps2(64)}"
          end

          def star_two
            # logger.warn "Star one answer: #{steps(64)}"
          end
        end
      end
    end
  end
end
