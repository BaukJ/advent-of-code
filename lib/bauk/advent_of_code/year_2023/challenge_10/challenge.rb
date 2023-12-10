# frozen_string_literal: true

require_relative "../../base_challenge"

# 772 too hight
# 248 too low

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge10
        # Challenge for 2023/10
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            puts @map
            @loop = {}
            @map.cells_with_row_column.each do |cell, row, column|
              next unless cell != [] && cell[:char] == "S"

              die "Too many S's!" unless @loop.empty?
              @start_cell = cell
            end
            logger.warn "Start cell: #{@start_cell.inspect}"
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one # rubocop:disable Metrics/AbcSize
            @ends = [@start_cell]
            until @ends.empty?
              logger.debug "ENDS: #{@ends.inspect}"
              new_ends = []
              @ends.each do |e|
                if @loop["#{e[:row]}_#{e[:column]}"]
                  logger.debug "Connected loop!"
                  next
                end
                @loop["#{e[:row]}_#{e[:column]}"] = e
                e[:connections].each do |connection|
                  connected_cell = @map.cell connection[:cell][:row], connection[:cell][:column]
                  next if connected_cell.empty?

                  new_ends << connected_cell if connected_cell[:connections].map { |c| c[:cell] }.include?({row: e[:row], column: e[:column]})
                end
              end
              @ends = new_ends
            end
            # @loop.each_value do |cell|
            #   @map.cell(cell[:row], cell[:column])[:char] = "#"
            # end
            # puts @map
            logger.warn "Star one answer: #{@loop.length / 2}"
          end

          def cell_to_key(cell)
            "#{cell[:row]}_#{cell[:column]}"
          end
          
          def calculate_sides(previous_cell, cell)
            # puts "ALCULATE_SIDES: #{cell.inspect}"
            direction = previous_cell[:connections].select { |d| d[:cell][:row] == cell[:row] && d[:cell][:column] == cell[:column] }.first
            source_cells = cell[:source_cells][cell_to_key(previous_cell)]
            source_cells[0].each do |left|
              unless @left_cells[cell_to_key(left)]
                add_padding left, @left_cells
              end
            end
            source_cells[1].each do |right|
              unless @right_cells[cell_to_key(right)]
                add_padding right, @right_cells
              end
            end
          end

          def add_padding(cell, cell_list)
            # puts "ADD PADDING: #{cell.inspect}"
            key = cell_to_key(cell)
            return if @checked_cells[key]
            # puts @checked_cells.length.inspect
            # puts @map.cells.length
            @checked_cells[key] = true

            return if cell_list[key] || @loop[key]
            if cell[:row] < 0 || cell[:column] < 0 || cell[:row] >= @map.row_max_index || cell[:column] >= @map.column_max_index
              cell_list["X"] = true
              return
            end
            cell_list[key] = cell

            @map.adjacent_4_cells_with_row_column(cell[:row], cell[:column]).each do |c, row, column|
              # puts "Adding more padding: #{row}/#{column}"
              # puts c.inspect
              # add_padding({row:, column:}, cell_list) if c.empty?
              add_padding({row:, column:}, cell_list) unless @checked_cells[cell_to_key({row:, column:})]
            end
          end

          def star_two # rubocop:disable Metrics/AbcSize
            @left_cells = {}
            @right_cells = {}
            @checked_cells = {}
            @previous_end = @start_cell
            @end = @start_cell[:connections].map { |c| @loop["#{c[:cell][:row]}_#{c[:cell][:column]}"] }.select do |e|
              e && e[:connections].map { |c| c[:cell] }.include?({row: @start_cell[:row], column: @start_cell[:column]})
            end.first # Go one way round
            while @end != @start_cell
              calculate_sides(@previous_end, @end)

              logger.debug "PREVIOUS END: #{@previous_end.inspect}"
              logger.debug "END: #{@end.inspect}"
              next_ends = @end[:connections].reject { |c| c[:cell][:row] == @previous_end[:row] && c[:cell][:column] == @previous_end[:column] }
              die "Too many (or not enough) ends: #{next_ends.inspect}" if next_ends.length != 1

              @previous_end = @end
              @end = @loop["#{next_ends[0][:cell][:row]}_#{next_ends[0][:cell][:column]}"]
            end
            # calculate_sides @start_cell


            if @left_cells["X"] && @right_cells["X"]
              die "No looped cells found! :("
            elsif @left_cells["X"]
              looped_cells = @right_cells
            elsif @right_cells["X"]
              looped_cells = @left_cells
            else
              # looped_cells = @right_cells
              die "2 looped cells found..."
            end
            looped_cells.each_value do |cell|
              @map.replace_cell cell[:row], cell[:column], {char: "*"}
            end
            puts @map
            logger.warn "Star two answer: #{looped_cells.length}"
          end
        end
      end
    end
  end
end
