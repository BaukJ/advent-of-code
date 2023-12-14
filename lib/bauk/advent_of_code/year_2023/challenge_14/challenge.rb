# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge14
        # Challenge for 2023/14
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def add_load(index)
            @load += (@map.row_count - index)
          end

          def roll(lists)
            lists.each do |list|
              free_index = false
              list.each_with_index do |cell, index|
                if cell.include? "#"
                  free_index = false
                elsif cell.empty?
                  free_index = index if not free_index
                elsif cell.include? "O"
                  if free_index
                    cell.delete "O"
                    list[free_index] << "O"
                    free_index += 1
                  end
                else
                  die "ERROR #{cell.inspect}"
                end
              end
            end
          end
          
          def calculate_load
            @load = 0
            @map.columns.each do |column|
              column.each_with_index do |cell, index|
                next unless cell.include? "O"

                add_load index
              end
            end
          end

          def roll_cycle
            roll @map.columns
            roll @map.rows
            roll @map.columns.map { |c| c.reverse }
            roll @map.rows.map { |r| r.reverse }
            calculate_load
          end

          def star_one
            @load = 0
            roll(@map.columns)
            puts @map
            logger.warn "Star one answer: #{@load}"
          end

          def star_two
            @cycles = 1000000000
            # @cycles = 500
            @loads = {}
            @looped = false
            cycle = 0
            old_map = @map.to_s
            @loop_cycle = []
            @looped = false
            while cycle <= @cycles
              cycle += 1
              old_load = @load
              if @loads[old_map]
                unless @looped
                  start_index = @loop_cycle.index old_map
                  @loop_cycle = @loop_cycle[start_index..]
                  @looped = true

                  left_cycles = @cycles - cycle
                  left_cycles %= @loop_cycle.length
                  # puts left_cycles
                  cycle = @cycles - left_cycles + 1
                end
                puts "#{cycle}/#{@cycles} #{@load} #{@loads[old_map][:load]}"
                @load = @loads[old_map][:load]
                old_map = @loads[old_map][:map]
              else
                @loop_cycle << old_map
                puts "#{cycle}/#{@cycles} #{@load} #{@loads[old_map]}"
                roll_cycle
                @loads[old_map] = {map: @map.to_s, load: @load}
                old_map = @map.to_s
              end
              # puts @map.to_s_with_border
            end
            logger.warn "Star two answer: #{@load}"
          end
        end
      end
    end
  end
end
