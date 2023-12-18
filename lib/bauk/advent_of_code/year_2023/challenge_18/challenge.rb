# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge18
        # Challenge for 2023/18
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.new 1, 1
            @row = 0
            @column = 0
            @map.insert @row, @column, "#"
            puts @map.to_s_with_border
            puts @map.to_s_with_border
          end

          def expand(direction)
            case direction
            when :U
              if @row.negative?
                @map.insert_row 0
                @row += 1
              end
            when :D
              @map.insert_row if @row > @map.row_max_index
            when :L
              if @column.negative?
                @column += 1
                @map.insert_column 0
              end
            when :R
              @map.insert_column if @column > @map.column_max_index
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def dig
            @rows = [[]]
            @lines.each do |line|
              die unless line =~ /^([UDLR]) ([0-9]+) *\(#(.*)(.)\)$/
              if @star_one
                direction = $1.to_sym
                steps = $2.to_i
              else
                direction = case $4.to_i
                            when 0 then :R
                            when 1 then :D
                            when 2 then :L
                            when 3 then :U
                            else die
                            end
                steps = $3.to_i(16)
              end
              dig_line2(direction, steps)
            end
            @rows.map! { |row| row.sort_by{|cell| cell[:column]}.uniq }
            # puts @rows.inspect
            show_map
            # fill_trench
            # show_map
          end

          def dig_line2(direction, steps)
            logger.debug { "DIG2: #{direction} #{steps}" }
            # show_map
            case direction
            when :R then dig_line2_right steps
            when :D then dig_line2_down steps
            when :U then dig_line2_up steps
            when :L then dig_line2_left steps
            end
          end

          def dig_line2_right(steps)
            @column += steps
            @rows[@row] << {column: @column, join: :left }
          end

          def dig_line2_left(steps)
            @column -= steps
            @rows[@row] << {column: @column, join: :right }
          end

          def dig_line2_down(steps)
            ((@row + 1)..(@row + steps)).each do |row|
              @rows << [] if row >= @rows.length
              @rows[row] << {column: @column, vertical: true}
            end
            @row += steps
          end

          def dig_line2_up(steps)
            ((@row - steps)..(@row - 1)).to_a.reverse.each do |row|
              if row.negative?
                @rows.insert(0, [{column: @column, vertical: true}])
              else
                @rows[row] << {column: @column, vertical: true}
              end
            end
            @row -= steps
            @row = 0 if @row.negative?
          end

          def show_map
            @rows.each do |row|
              (0..row[0][:column]).each { putc "."}
              inside = false
              (1...row.length).each do |index|
                line_start = row[index - 1]
                line_end = row[index]
                inside = !inside if line_start[:vertical] || line_start[:join] == :left
                on_line = line_start[:join] == :right || line_end[:join] == :left
                (line_start[:column]...line_end[:column]).each do |i|
                  if inside then putc "#"
                  elsif on_line then putc "*"
                  else putc "."
                  end
                  # putc inside || on_line ? "#" : "."
                end
              end
              putc "#"
              puts
            end
            sleep 0.1
          end

          def calculate_dug
            @dug = 0
            @rows.each do |row|
              inside = false
              (1...row.length).each do |index|
                line_start = row[index - 1]
                line_end = row[index]
                inside = !inside if line_start[:vertical]
                on_line = line_start[:join] == :right || line_end[:join] == :left
                (line_start[:column]...line_end[:column]).each do |i|
                  @dug += 1 if inside || on_line
                end
              end
              @dug += 1
            end
            @dug
          end

          def star_one
            @star_one = true
            dig
            logger.warn "Star one answer: #{calculate_dug}"
          end

          def star_two
            @star_one = false
            # dig
            # logger.warn "Star two answer: #{calculate_dug}"
          end
        end
      end
    end
  end
end

#80169 high