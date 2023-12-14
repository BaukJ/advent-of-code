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
            # star_one
            star_two
          end

          def add_load(index)
            @load += (@map.row_count - index)
          end

          def roll(lists)
            @load = 0
            lists.each do |list|
              list.each_with_index do |cell, index|
              end
            end
          end

          def star_one
            @load = 0
            @map.columns.each_with_index do |column, column_index|
              free_index = false
              column.each_with_index do |cell, index|
                if cell.include? "#"
                  free_index = false
                elsif cell.empty?
                  free_index = index if not free_index
                elsif cell.include? "O"
                  if free_index
                    cell.delete "O"
                    column[free_index] << "O"
                    add_load free_index
                    free_index += 1
                  else
                    add_load index
                  end
                else
                  die "ERROR #{cell.inspect}"
                end
              end
            end
            puts @map
            logger.warn "Star one answer: #{@load}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
