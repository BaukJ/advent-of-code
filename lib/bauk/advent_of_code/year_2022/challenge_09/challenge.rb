# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge09
        # Challenge for 2022/09
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            # @map = Map.new 2, 2
            # puts @map
            # puts @map.cell(0, 0).inspect
            # @knots = (0..9).map { {row: 0, column: 0}}
            @head_row = 0
            @head_column = 0
            @tail_row = 0
            @tail_column = 0
            @tail_visits = {}
            @tail_visits["#{@tail_row}_#{@tail_column}"] = {row: @tail_row, column: @tail_column} # Starting position
            @max_row = 0
            @max_column = 0
            @min_row = 0
            @min_column = 0
          end

          def show_map
            @max_row = [@max_row, @head_row, @tail_row].max
            @max_column = [@max_column, @head_column, @tail_column].max
            @min_row = [@min_row, @head_row, @tail_row].min
            @min_column = [@min_column, @head_column, @tail_column].min
            map = Map.new @max_row + 1 - @min_row, @max_column + 1 - @min_row
            map.allow_multiples = true
            map.insert @head_row - @min_row, @head_column - @min_column, "H"
            map.insert @tail_row - @min_row, @tail_column - @min_column, "T"
            puts map.to_s_with_border
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def update_tail
            row_diff = @head_row - @tail_row
            column_diff = @head_column - @tail_column
            logger.debug { "Update start) H: #{@head_row}/#{@head_column} T:#{@tail_row}/#{@tail_column}" }
            return if row_diff.between?(-1, 1) && column_diff.between?(-1, 1)

            if column_diff.negative?
              @tail_column -= 1
            elsif column_diff.positive?
              @tail_column += 1
            end
            if row_diff.negative?
              @tail_row -= 1
            elsif row_diff.positive?
              @tail_row += 1
            end
            @tail_visits["#{@tail_row}_#{@tail_column}"] = {row: @tail_row, column: @tail_column}
            logger.debug { "Update end  ) H: #{@head_row}/#{@head_column} T:#{@tail_row}/#{@tail_column}" }
          end

          def star_one
            @lines.each do |line|
              die "Invalid line: #{line}" unless line =~ /^([UDLR]) ([0-9]+)$/

              (1..$2.to_i).each do
                case $1
                when "U"
                  @head_row -= 1
                when "D"
                  @head_row += 1
                when "L"
                  @head_column -= 1
                when "R"
                  @head_column += 1
                end
                update_tail
                # show_map
              end
            end
            logger.warn "Star one answer: #{@tail_visits.length}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
