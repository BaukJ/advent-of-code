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

          def steps3(count) # rubocop:disable Metrics/AbcSize
            gone = {"#{@row}_#{@column}" => :E}
            positions = [{row: @row, column: @column}]
            @map = @original_map.deep_clone
            even = true
            old_position_count = 0
            old_gone_count = 0
            gone_counts = []
            count.times do |round|
              logger.info { "#{round}) Gone: #{gone.length}, Positions: #{positions.length}" } if round % 10 == 0
              # if (round-65) % 131 == 0
              #   gone_count = gone.length
              #   gone_counts << gone_count
              #   find_pattern(gone_counts) if gone_counts.length > 2
              #   position_count = positions.length
              #   puts "#{round}) Gone: #{gone_count} (+#{gone_count - old_gone_count}), Positions: #{position_count} (+#{position_count-old_position_count})"
              #   old_position_count = position_count
              #   old_gone_count = gone_count
              # end
              # puts positions.map { |p| p[:row] }.max / @map.row_count
              even = !even
              new_positions = []
              positions.each do |position|
                # if position[:row] == 65 && position[:column] % @map.column_count == 0
                #   puts round
                # end
                # if position[:row] % @map.row_count == 0
                #   puts "COLUMN: #{position[:column] % @map.column_count} #{even}"
                # elsif position[:column] % @map.column_count == 0
                #   puts "ROW: #{position[:row] % @map.row_count} #{even}"
                # end
                # if (position[:row] % @map.row_count) == @row && (position[:column] % @map.column_count) == @column
                #   puts even
                # end
                get_4_moves(position[:row], position[:column]).each do |move|
                  gone_key = "#{move[:row]}_#{move[:column]}"
                  if free_space?(move) && !gone[gone_key]
                    new_positions << move
                    gone[gone_key] = even ? :E : :e
                  end
                end
              end
              positions = new_positions.uniq
            end
            gone.values.select { |v| v == (even ? :E : :e) }.length
          end

          def find_pattern(list)
            pattern = [list]
            until pattern[-1].all? { |n| n.zero? } || pattern[-1].length < 2
              puts pattern[-1].inspect
              from = pattern[-1]
              pattern << []
              (0...(from.length-1)).each do |i|
                pattern[-1] << (from[i+1] - from[i])
              end
            end
          end

          # DEPENDS on there being a straight line to the ends, and there being exactly the same steps to each end!
          # AND! the number you want being 131*n + 65....
          # Pattern is... gone = 
          def steps4(count) # rubocop:disable Metrics/AbcSize
            gone_count = 0
            count -= 65
            rounds = count / 131
            
            incrementer = 59484
            pattern = [[7418], [59482]]
            rounds.times do |round|
              pattern[-1] << pattern[-1][-1] + incrementer
              pattern[0] << pattern[0][-1] + pattern[-1][-2]
            end
            # puts pattern.inspect
            pattern[0][-1]
          end

          def get_4_moves(row, column)
            [
              {row:, column: column + 1},
              {row:, column: column - 1},
              {row: row + 1, column:},
              {row: row - 1, column:}
            ]
          end

          def free_space?(position)
            row = position[:row] % @map.row_count
            column = position[:column] % @map.column_count
            @map.empty? row, column
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
            # return
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
            # [6, 10, 50, 100, 500, 5000].each do |n|
            #   logger.warn "Test: #{n} -> #{steps3(n)}"
            # end
            # logger.warn "Star one answer: 64 -> #{steps2(64)}"
          end

          def star_two
            test = 65
            while test < 100
              logger.warn "Star one answer: #{steps3(test)}"
              logger.warn "Star one answer: #{steps4(test)}"
              test += 131
            end
            # logger.warn "Star one answer: #{steps4(26501365)}"
          end
        end
      end
    end
  end
end

# Too high: 1217205991589418