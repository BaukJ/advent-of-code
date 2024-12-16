# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge16
        # Challenge for 2024/16
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            @map.reset_cell(@map.row_max_index - 1, 1)
            @map.reset_cell(1, @map.column_max_index - 1)
            @symbols = {
              0 => "^",
              1 => ">",
              2 => "v",
              3 => ">"
            }
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one if [0, 1].include? Opts.star
            star_two if [0, 2].include? Opts.star
          end

          def star_one
            @heads = [{ row: @map.row_max_index - 1, column: 1, facing: 1, score: 0, visited: [{ row: @map.row_max_index - 1, column: 1 }] }]
            @been = {}
            print_points @heads
            @round = 0
            until @heads.empty?
              @round += 1
              move_all
              if Opts.show
                print_points @heads
                sleep Opts.sleep
              end
            end
            logger.warn "Star one answer: #{@score}"
          end

          def move_all
            old_heads = @heads
            @heads = []
            old_heads.each do |head|
              clockwise = head.deep_clone
              clockwise[:score] += 1000
              clockwise[:facing] += 1
              clockwise[:facing] %= 4
              add_head(clockwise)
              anticlockwise = head.deep_clone
              anticlockwise[:score] += 1000
              anticlockwise[:facing] -= 1
              anticlockwise[:facing] %= 4
              add_head(anticlockwise)
              forward = head.deep_clone
              forward[:score] += 1
              case forward[:facing]
              when 0
                forward[:row] -= 1
                next if forward[:row].negative?
              when 1
                forward[:column] += 1
                next if forward[:column] > @map.column_max_index
              when 2
                forward[:row] += 1
                next if forward[:row] > @map.row_max_index
              when 3
                forward[:column] -= 1
                next if forward[:column].negative?
              end
              add_head(forward) if @map.cell(forward[:row], forward[:column]).empty?
            end
          end

          def add_head(head)
            head[:visited] << { row: head[:row], column: head[:column] }
            if head[:row] == 1 && head[:column] == @map.column_max_index - 1
              # We've finished
              if @score.nil? || head[:score] < @score
                @all_visited = []
                @score = head[:score]
              elsif head[:score] > @score
                return
              end
              logger.warn "Finished! (score: #{head[:score]})"
              print_visits head[:visited]
              @all_visited += head[:visited]
              # print_points(head[:visited])
            end
            key = point_to_key(head)
            if @been.key? key
              logger.debug "Comparing #{key}: return if #{@been[key]} <= #{head[:score]}"
              return if @been[key] < head[:score]
            end
            @been[key] = head[:score]
            @heads << head
          end

          def point_to_key(point)
            "#{point[:row]}_#{point[:column]}_#{point[:facing]}"
          end

          def print_points(points)
            map = @map.deep_clone
            points.each do |point|
              # puts "cell: #{point} -> #{map.cell(point[:row], point[:column])}"
              if map.cell(point[:row], point[:column]).empty?
                map.replace_cell(point[:row], point[:column], @symbols[point[:facing]])
              else
                map.replace_cell(point[:row], point[:column], "*")
              end
            end
            puts map
            puts "count: #{points.length}"
          end

          def print_visits(visits)
            visits = visits.uniq
            map = @map.deep_clone
            visits.each do |visit|
              map.insert(visit[:row], visit[:column], "O")
            end
            puts map
          end

          def star_two
            @all_visited.uniq!
            print_visits @all_visited
            logger.warn "Star two answer: #{@all_visited.length}"
          end
        end
      end
    end
  end
end
