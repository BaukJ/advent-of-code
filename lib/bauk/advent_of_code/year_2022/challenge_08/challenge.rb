# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge08
        # Challenge for 2022/08
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.new(@lines.length, @lines[0].length)
            @lines.each_with_index do |row, row_index|
              row.chars.each_with_index do |tree, column_index|
                @map.insert row_index, column_index, tree.to_i
              end
            end
            @visible_map = Map.new(@lines.length, @lines[0].length)
            find_visible_trees
            find_most_scenic
          end

          def find_most_scenic
            most_scenic = 0
            (0..@map.row_max_index).each do |row|
              (0..@map.column_max_index).each do |column|
                score = calculate_scenic_score row, column
                most_scenic = score if score > most_scenic
              end
            end
            logger.warn "Most scenic tree: #{most_scenic}"
          end

          def calculate_scenic_score(row, column)
            height = @map.cell(row, column)[0]
            left = calculate_visible_trees(@map.line_of_cells([{ row:, column: }, { row:, column: 0 }])[1..], height)
            right = calculate_visible_trees(@map.line_of_cells([{ row:, column: }, { row:, column: @map.column_max_index }])[1..], height)
            up = calculate_visible_trees(@map.line_of_cells([{ row:, column: }, { row: 0, column: }])[1..], height)
            down = calculate_visible_trees(@map.line_of_cells([{ row:, column: }, { row: @map.row_max_index, column: }])[1..], height)
            logger.info "LEFT: #{left}, right: #{right}, up: #{up}, down: #{down}"
            down * up * left * right
          end

          def calculate_visible_trees(trees, max_height)
            logger.debug "Max: #{max_height}, Trees: #{trees.flatten.inspect}"
            count = 0
            trees.flatten.each do |tree|
              count += 1
              break if tree >= max_height
            end
            count
          end

          def find_visible_trees # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
            @visible = {}
            @map.rows.each_with_index do |row, row_index|
              height = -1
              row.flatten.each_with_index do |tree, column_index|
                next unless tree > height

                height = tree
                @visible["#{row_index}_#{column_index}"] = true
                @visible_map.insert(row_index, column_index, "V")
              end

              height = -1
              row.flatten.reverse.each_with_index do |tree, column_index|
                next unless tree > height

                height = tree
                @visible["#{row_index}_#{@map.column_max_index - column_index}"] = true
                @visible_map.remove(row_index, @map.column_max_index - column_index, "V")
                @visible_map.insert(row_index, @map.column_max_index - column_index, "V")
              end
            end

            @map.columns.each_with_index do |column, column_index|
              height = -1
              column.flatten.each_with_index do |tree, row_index|
                next unless tree > height

                height = tree
                @visible["#{row_index}_#{column_index}"] = true
                @visible_map.remove(row_index, column_index, "V")
                @visible_map.insert(row_index, column_index, "V")
              end

              height = -1
              column.flatten.reverse.each_with_index do |tree, row_index|
                next unless tree > height

                height = tree
                @visible["#{@map.row_max_index - row_index}_#{column_index}"] = true
                @visible_map.remove(@map.row_max_index - row_index, column_index, "V")
                @visible_map.insert(@map.row_max_index - row_index, column_index, "V")
              end
            end
            # puts @visible_map
            logger.warn "Visible trees: #{@visible.length}"
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
          end
        end
      end
    end
  end
end
