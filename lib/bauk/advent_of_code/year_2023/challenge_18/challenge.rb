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
            @row = 0
            @column = 0
            @max_column = 0
            @min_column = 0
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def dig
            @rows = {}
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
            # puts @rows.inspect
            # show_map
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
            @rows[@row] ||= {}
            new_column = @column + steps
            @rows[@row][@column] = new_column
            @column = new_column
            @max_column = @column if @column > @max_column
          end

          def dig_line2_left(steps)
            @rows[@row] ||= {}
            new_column = @column - steps
            @rows[@row][new_column] = @column
            @column = new_column
            @min_column = @column if @column < @min_column
          end

          def dig_line2_down(steps)
            @row += steps
          end

          def dig_line2_up(steps)
            @row -= steps
          end

          def show_map # rubocop:disable Metrics/AbcSize
            start_index = 0
            @previous_row = {}
            @rows.keys.sort.each do |row_index| # rubocop:disable Metrics/BlockLength
              row = @rows[row_index]
              # puts "#{start_index} => #{row_index}"
              ((start_index + 1)...row_index).each do
                # puts "Adding empty row: #{@previous_row.select{ |c| puts c }.length} #{@previous_row.inspect}"
                (@min_column..@max_column).each do |column|
                  putc @previous_row[column] ? "#" : "."
                end
                puts
              end

              start_index = row_index
              start = @min_column - 1
              @this_row = @previous_row.dup
              line_end = nil
              row.keys.sort.each do |line_start|
                line_end = row[line_start]
                ((start + 1)...line_start).each { |c| putc @previous_row[c] ? "#" : "." }
                (line_start..line_end).each do |column|
                  putc "#"
                  @this_row[column] = if @previous_row[column]
                                        if (column == line_start && @previous_row[column - 1]) || (column == line_end && @previous_row[column + 1])
                                          true
                                        else
                                          false
                                        end
                                      else
                                        true
                                      end
                end
                start = line_end
              end
              ((line_end + 1)..@max_column).each { |c| putc @previous_row[c] ? "#" : "." }
              puts
              @previous_row = @this_row
            end
            sleep 0.1
          end

          def calculate_dug
            @dug = 0
            start_index = 0
            @previous_row = {}
            row_keys = @rows.keys.sort
            on_row = 0
            row_keys.each do |row_index| # rubocop:disable Metrics/BlockLength
              on_row += 1
              logger.info { "Calculating dug GAP for row: #{on_row} out of #{row_keys.length}" }
              row = @rows[row_index]
              previously_dug = @previous_row.length
              @dug += previously_dug * (row_index - start_index - 1)

              logger.debug { "Calculating dug MAIN for row: #{on_row} out of #{row_keys.length}" }
              start_index = row_index
              start = @min_column - 1
              @this_row = @previous_row.dup
              line_end = nil
              row.keys.sort.each do |line_start|
                line_end = row[line_start]
                previously_dug = @previous_row.keys.select { |k| k > start && k < line_start }.count
                @dug += previously_dug
                (line_start..line_end).each do |column|
                  @dug += 1
                  if @previous_row[column]
                    @this_row.delete(column) unless (column == line_start && @previous_row[column - 1]) || (column == line_end && @previous_row[column + 1])
                  else
                    @this_row[column] = true
                  end
                end
                start = line_end
              end

              logger.debug { "Calculating dug AFTER for row: #{on_row} out of #{row_keys.length}" }

              previously_dug = @previous_row.keys.select { |k| k > line_end && k <= @max_column }.count
              @dug += previously_dug
              @previous_row = @this_row
            end
            puts @dug
            @dug
          end

          def star_one
            @star_one = true
            dig
            logger.warn "Star one answer: #{calculate_dug}"
          end

          def star_two
            @star_one = false
            dig
            logger.warn "Star two answer: #{calculate_dug}"
          end
        end
      end
    end
  end
end

# 80169 high
