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
            start = @map.cells_with_row_column.select { |cell, _r, _c| cell.include? "S" }.last
            @row = start[1]
            @column = start[2]
            @map.remove @row, @column, "S"
            @original_map = @map.deep_clone
          end

          def steps(count)
            positions = [{ row: @row, column: @column }]
            count.times do
              # show_positions(positions)
              new_positions = []
              positions.each do |position|
                @map.adjacent_4_cells_with_row_column(position[:row], position[:column]).each do |cell, row, column|
                  new_positions << { row:, column: } if cell.empty?
                end
              end
              positions = new_positions.uniq
              check_map_size(positions)
            end
            positions.length
          end

          def steps2(count) # rubocop:disable Metrics/AbcSize
            positions = [{ row: @row, column: @column }]
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
                    new_positions << { row:, column: }
                    @map.insert row, column, even ? :E : :e
                  end
                end
              end
              positions = new_positions.uniq
              check_map_size(positions)
            end
            @map.cells.select { |cell| cell.include?(even ? :E : :e) }.length
          end

          def steps3(count) # rubocop:disable Metrics/AbcSize
            gone = { "#{@row}_#{@column}" => :E }
            positions = [{ row: @row, column: @column }]
            @map = @original_map.deep_clone
            even = true
            old_position_count = 0
            old_gone_count = 0
            gone_counts = []
            gone_all_counts = []
            gone_true_counts = []
            gone_false_counts = []
            count.times do |round|
              logger.info { "#{round}) Gone: #{gone.length}, Positions: #{positions.length}" } if (round % 10).zero?
              if ((round - 65) % 131).zero?
                gone_count = gone.length
                gone_true_count = gone.values.select { |v| v == :E }.length
                gone_false_count = gone.values.reject { |v| v == :E }.length
                gone_true_counts << gone_true_count
                gone_false_counts << gone_false_count
                gone_all_counts << { E: gone_true_count, e: gone_false_count, even: }
                gone_counts << gone_count
                if gone_counts.length > 9
                  find_pattern(gone_true_counts)
                  find_pattern(gone_false_counts)
                  exit
                end
                position_count = positions.length
                # puts "#{round}) Gone: #{gone_count} (+#{gone_count - old_gone_count}), Positions: #{position_count} (+#{position_count-old_position_count})"
                old_position_count = position_count
                old_gone_count = gone_count
              end
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
            until pattern[-1].all?(&:zero?) || pattern[-1].length < 2
              puts pattern[-1].inspect
              from = pattern[-1]
              pattern << []
              (0...(from.length - 1)).each do |i|
                pattern[-1] << (from[i + 1] - from[i])
              end
            end
          end

          # DEPENDS on there being a straight line to the ends, and there being exactly the same steps to each end!
          # AND! the number you want being 131*n + 65....
          # Pattern is... gone =
          def steps4(count) # rubocop:disable Metrics/AbcSize
            count -= 65
            rounds = count / 131

            # pattern = [
            #   {E: 3642, e: 3776},
            #   {E: 33652, e: 33248},
            #   {E: 92596, e: 93270},
            #   {E: 182630, e: 181686},
            #   {E: 300518, e: 301732},
            #   {E: 450576, e: 449092},
            #   {E: 627408, e: 629162},
            #   {E: 837490, e: 835466},
            #   {E: 1073266, e: 1075560},
            #   {E: 1343372, e: 1340808},
            #   # {E: , e: },
            #   # {E: , e: },
            # ]
            # find_pattern pattern.map { |p| p[:E] }.each_slice(2).map(&:first)
            # find_pattern pattern.map { |p| p[:E] }.each_slice(2).map(&:last)
            # exit

            incrementer = 118_968
            even = false
            pattern = [[{ e: 3776, E: 3642 }, { e: 33_248, E: 33_652 }], [{ e: 89_494, E: 88_954 }, { e: 148_438, E: 148_978 }]]
            # puts "ROUNDS: #{rounds}"
            rounds.times do
              # puts pattern.inspect
              even = !even
              pattern[-1] << {}
              pattern[0] << {}
              %i[e E].each do |e|
                pattern[-1][-1][e] = pattern[-1][-3][e] + incrementer
                pattern[0][-1][e] = pattern[0][-3][e] + pattern[-1][-3][e]
              end
              # pattern[-1] << pattern[-1][-1] + incrementer
              # pattern[0] << pattern[0][-1] + pattern[-1][-2]
            end
            # puts pattern.inspect
            pattern[0][-2][even ? :E : :e]
          end

          def get_4_moves(row, column)
            [
              { row:, column: column + 1 },
              { row:, column: column - 1 },
              { row: row + 1, column: },
              { row: row - 1, column: }
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
              elsif (position[:row]).zero?
                positions.each do |pos|
                  pos[:row] += @map.row_count
                end
                add_map_up
                check_map_size(positions)
                break
              elsif (position[:column]).zero?
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
              column.each do |c|
                c.delete(:e)
                c.delete(:E)
              end
              @map.insert_column(-1, column)
            end
          end

          def add_map_left
            @map.deep_clone.columns.reverse.each do |column|
              column.each do |c|
                c.delete(:e)
                c.delete(:E)
              end
              @map.insert_column(0, column)
            end
          end

          def add_map_down
            @map.deep_clone.rows.each do |row|
              row.each do |c|
                c.delete(:e)
                c.delete(:E)
              end
              @map.insert_row(-1, row)
            end
          end

          def add_map_up
            @map.deep_clone.rows.reverse.each do |row|
              row.each do |c|
                c.delete(:e)
                c.delete(:E)
              end
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
            # logger.warn "Star one answer: #{steps3(1000000)}"
            # logger.warn "Star one answer: #{steps4(1000)}"
            # while test < 1000
            #   logger.warn "Testing #{test}:"
            #   logger.warn "Star step3 answer: #{steps3(test)}"
            #   logger.warn "Star step4 answer: #{steps4(test)}"
            #   test += 131
            # end
            logger.warn "Star one answer: #{steps4(26_501_365)}"
          end
        end
      end
    end
  end
end

# Too high: 1217205991589418
