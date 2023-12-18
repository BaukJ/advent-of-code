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
              dig_line(direction, steps)
            end
            show_map
            fill_trench
            show_map
          end

          def fill_trench
            inside = false
            @map.row(1).each_with_index do |cell, index|
              if !cell.empty?
                inside = !inside
              elsif inside
                fill_empties(1, index)
                return
              end
            end
            # @map.rows.each do |row|
            #   previous_empty = true
            #   row.each do |cell|
            #     this_empty = cell.empty?
            #     if previous_empty && !this_empty
            #       inside = !inside
            #     elsif inside && this_empty
            #       cell << "#"
            #     end
            #     previous_empty = this_empty
            #   end
            # end
          end

          def fill_empties(row, column)
            empties = [{row:, column:}]
            until empties.empty?
              # show_map
              new_empties = []
              # puts empties.inspect
              empties.each do |empty|
                @map.insert empty[:row], empty[:column], "#"
              end
              empties.each do |empty| # rubocop:disable Style/CombinableLoops
                @map.adjacent_8_cells_with_row_column(empty[:row], empty[:column]).each do |cell, r, c|
                  # puts "#{cell}, #{r}/#{c} #{cell.empty?}"
                  new_empties << {row: r, column: c} if cell.empty?
                end
                empties = new_empties.uniq
              end
            end
          end

          def dig_line(direction, steps)
            logger.debug { "DIG: #{direction} #{steps}"}
            case direction
            when :U
              (1..steps).each do
                @row -= 1
                post_dig direction
              end
            when :D
              (1..steps).each do
                @row += 1
                post_dig direction
              end
            when :L
              (1..steps).each do
                @column -= 1
                post_dig direction
              end
            when :R
              (1..steps).each do
                @column += 1
                post_dig direction
              end
            end
          end

          def post_dig(direction)
            expand(direction)
            if @map.empty? @row, @column
              @map.insert @row, @column, "#"
              show_map
            else
              logger.warn "Hit an empty block: #{@row}/#{@column}"
            end
          end

          def show_map
            puts @map.to_s_with_border
            sleep 0.1
          end

          def star_one
            # dig
            logger.warn "Star one answer: #{@map.cells.flatten.length}"
          end

          def star_two
            dig
            logger.warn "Star two answer: #{@map.cells.flatten.length}"
          end
        end
      end
    end
  end
end

#80169 high