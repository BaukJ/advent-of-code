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
          end

          def reset(knots)
            @knots = (0..knots).map { { row: 0, column: 0 } }
            @tail_visits = {}
            update_tail_visits
            @max_row = 0
            @max_column = 0
            @min_row = 0
            @min_column = 0
          end

          def show_map
            @max_row = [@max_row, @knots[0][:row]].max
            @max_column = [@max_column, @knots[0][:column]].max
            @min_row = [@min_row, @knots[0][:row]].min
            @min_column = [@min_column, @knots[0][:column]].min
            map = Map.new @max_row + 1 - @min_row, @max_column + 1 - @min_row
            map.allow_multiples = true
            @knots.each_with_index do |knot, index|
              map.insert knot[:row] - @min_row, knot[:column] - @min_column, index
            end
            puts map.to_s_with_border
            sleep 1
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def update_tail_visits
            @tail_visits["#{@knots[-1][:row]}_#{@knots[-1][:column]}"] = { row: @knots[-1][:row], column: @knots[-1][:column] }
          end

          def update_knots
            (1...@knots.length).each do |i|
              update_knot @knots[i], @knots[i - 1]
            end
            update_tail_visits
          end

          def update_knot(knot, head) # rubocop:disable Metrics/AbcSize
            row_diff = head[:row] - knot[:row]
            column_diff = head[:column] - knot[:column]
            logger.debug { "Update start) H: #{head[:row]}/#{head[:column]} T:#{knot[:row]}/#{knot[:column]}" }
            return if row_diff.between?(-1, 1) && column_diff.between?(-1, 1)

            if column_diff.negative?
              knot[:column] -= 1
            elsif column_diff.positive?
              knot[:column] += 1
            end
            if row_diff.negative?
              knot[:row] -= 1
            elsif row_diff.positive?
              knot[:row] += 1
            end
            logger.debug { "Update end  ) H: #{head[:row]}/#{head[:column]} T:#{knot[:row]}/#{knot[:column]}" }
          end

          def update_head(move)
            case move
            when "U"
              @knots[0][:row] -= 1
            when "D"
              @knots[0][:row] += 1
            when "L"
              @knots[0][:column] -= 1
            when "R"
              @knots[0][:column] += 1
            end
          end

          def star_one
            reset 1
            run_star
            logger.warn "Star one answer: #{@tail_visits.length}"
          end

          def run_star
            @lines.each do |line|
              die "Invalid line: #{line}" unless line =~ /^([UDLR]) ([0-9]+)$/

              (1..$2.to_i).each do
                update_head $1
                update_knots
                # show_map
              end
            end
            logger.debug "Tail poisitions: #{@tail_visits.keys.inspect}"
          end

          def star_two
            reset 9
            run_star
            logger.warn "Star two answer: #{@tail_visits.length}"
          end
        end
      end
    end
  end
end
