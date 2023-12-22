# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge22
        # Challenge for 2023/22
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @grid = [] # z, x, y
            @blocks = {}
            @lines.each_with_index do |line, index|
              brick_starts, brick_ends = line.split("~").map { |b| b.split(",").map(&:to_i) }
              (brick_starts[0]..brick_ends[0]).each do |x|
                (brick_starts[1]..brick_ends[1]).each do |y|
                  (brick_starts[2]..brick_ends[2]).each do |z|
                    # puts "#{index}) #{z}/#{x}/#{y}"
                    (@grid[z] ||= [])[x] ||= []
                    die if @grid[z][x][y]
                    @grid[z][x][y] = index
                    (@blocks[index] ||= []) << {z:, x:, y:}
                  end
                end
              end
            end
            fall
            # puts @grid.inspect
          end

          def fall
            any_fell = true
            # puts "Fall start"
            @fell = {}
            while any_fell
              any_fell = false
              @blocks.each do |index, block|
                free_to_fall = 10
                # puts "#{index}) #{block}"
                block.each do |position|
                  break if free_to_fall == 0
                  (1..free_to_fall).each do |fall_distance|
                    item_below = get_grid_position(position.merge({z: position[:z] - fall_distance}))
                    # puts "Checking z : #{{z: position[:z] - fall_distance}}"
                    break if item_below == index
                    if (position[:z] - fall_distance) <= 0 || !item_below.nil?
                      free_to_fall = fall_distance - 1
                      # puts position[:z] - free_to_fall
                      break
                    end
                  end
                end
                if free_to_fall > 0
                  # puts "FALL"
                  any_fell = true
                  @fell[index] = true
                  block.each do |position|
                    remove_grid_position(position)
                    position[:z] -= free_to_fall
                    add_grid_position(position, index)
                  end
                end
                # sleep 0.5
              end
            end
            # puts @grid.inspect
            # puts "Fall end"
          end

          def get_grid_position(position)
            @grid[position[:z]]&.[](position[:x])&.[](position[:y])
          end

          def remove_grid_position(position)
            @grid[position[:z]][position[:x]][position[:y]] = nil
          end

          def add_grid_position(position, item)
            ((@grid[position[:z]] ||= [])[position[:x]] ||= [])[position[:y]] = item
          end

          def find_disintegratable
            @rests = {}
            @supports = {}
            @blocks.each do |index, _block|
              @rests[index] = {}
              @supports[index] = {}
            end
            @blocks.each do |index, block|
              block.each do |position|
                below = get_grid_position(position.merge({z: position[:z]-1}))
                # puts "#{below} is below #{index}"
                unless below == index || below.nil?
                  @rests[index][below] = true
                  @supports[below][index] = true
                end
              end
            end
            @disintegratable = []
            @blocks.each do |index, _block|
              # puts "Checking block #{index}"
              can_remove = true
              # puts "Block supports: #{@supports[index]}"
              @supports[index].each do |supported, _|
                can_remove = false if @rests[supported].length == 1
              end
              if can_remove
                # puts "Can remove: #{index} (#{(index+65).chr})"
                @disintegratable << index
              end
            end
          end

          def calculate_block_falls
            @total_falls = 0
            check_blocks = @blocks.reject { |b, _| @disintegratable.include? b }
            @starting_blocks = @blocks
            @starting_grid = @grid
            check_blocks.each do |index, block|
              @grid = @starting_grid.deep_clone
              @blocks = @starting_blocks.deep_clone
              block.each do |position|
                remove_grid_position position
              end
              @blocks.delete index
              fall
              @total_falls += @fell.length
              puts "#{index} block would make #{@fell.length} fall"
            end
            # puts check_blocks.inspect
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            find_disintegratable
            logger.warn "Star one answer: #{@disintegratable.length}"
          end

          def star_two
            calculate_block_falls
            logger.warn "Star two answer: #{@total_falls}"
          end
        end
      end
    end
  end
end
