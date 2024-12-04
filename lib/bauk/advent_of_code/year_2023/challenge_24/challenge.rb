# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge24
        # Challenge for 2023/24
        class Challenge < BaseChallenge # rubocop:disable Metrics/ClassLength
          def initialize # rubocop:disable Metrics/AbcSize
            super
            @boundary_start = 7
            @boundary_end = 27
            @boundary_start = 200_000_000_000_000
            @boundary_end = 400_000_000_000_000
            @hails = []
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @lines.each_with_index do |line, index|
              parts = line.split(/[, @]+/).map(&:to_f)
              @hails << {
                id: index,
                x_start: parts[0],
                y_start: parts[1],
                z_start: parts[2],
                x_delta: parts[3],
                y_delta: parts[4],
                z_delta: parts[5],
                y: parse_y(parts[0], parts[1], parts[3], parts[4])
              }
              @hails[-1][0] = parse_0 @hails[-1][:y]
              die "Invalid line: #{line}" if parts[6] || !parts[5]
            end
            find_x_y_intersects
          end

          def parse_y(x_start, y_start, x_delta, y_delta)
            x = y_delta / x_delta
            x_steps = x_start / x_delta
            c = y_start - (x_steps * y_delta)
            logger.debug { "#{x_start}/#{y_start} +(#{x_delta}/#{y_delta}) => y = #{c} + #{x}x" }
            { c:, x: }
          end

          def parse_0(y) # rubocop:disable Naming/VariableNumber
            y_0 = 1
            x_0 = -y[:x]
            c_0 = -y[:c]
            logger.debug { "y = #{y[:c]} + #{y[:x]}x => 0 = y + #{x_0}x + #{c_0}" }
            { x: x_0, y: y_0, c: c_0 }
          end

          def find_x_y_intersect_from_0(hail_1, hail_2) # rubocop:disable Metrics/AbcSize,Naming/VariableNumber
            {
              x: ((hail_1[:y] * hail_2[:c]) - (hail_2[:y] * hail_1[:c])) / ((hail_1[:x] * hail_2[:y]) - (hail_2[:x] * hail_1[:y])),
              y: ((hail_2[:x] * hail_1[:c]) - (hail_1[:x] * hail_2[:c])) / ((hail_1[:x] * hail_2[:y]) - (hail_2[:x] * hail_1[:y]))
            }
          end

          def find_x_y_intersects
            @x_y_intersects = []
            @hails.each_with_index do |hail_1, index|
              ((index + 1)...@hails.length).each do |index_2|
                hail_2 = @hails[index_2]

                next if hail_1[:y][:x] == hail_2[:y][:x] # If they are parallel

                logger.debug { "#{hail_1} + #{hail_2}" }
                intersect = find_x_y_intersect_from_0 hail_1[0], hail_2[0]
                logger.debug { "INTERSECT: #{intersect} " }

                # Filter intersects outside boundary
                next unless intersect[:x].between?(@boundary_start, @boundary_end) && intersect[:y].between?(@boundary_start, @boundary_end)

                # Assuming no zero deltas!
                # Filter past intersects
                next if hail_1[:x_start] > intersect[:x] && hail_1[:x_delta].positive?
                next if hail_1[:x_start] < intersect[:x] && hail_1[:x_delta].negative?
                next if hail_2[:x_start] > intersect[:x] && hail_2[:x_delta].positive?
                next if hail_2[:x_start] < intersect[:x] && hail_2[:x_delta].negative?

                @x_y_intersects << intersect
              end
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            logger.warn "Star one answer: #{@x_y_intersects.length}"
          end

          def star_two
            find_start_position
            # find_first_hailstone
            # test_throw({x_start: 24, y_start: 13, z_start: 10, x_delta: -3, y_delta: 1, z_delta: 2})
            logger.warn "Star two answer: "
          end

          # Assuming all collisions happen at a point/exact nanosecond (not on a line or between nanoseconds!)
          # x_start, y_start, z_start, x_delta, y_delta, z_delta
          # Abuse ?_start as ?_current
          def test_throw(ball) # rubocop:disable Metrics/AbcSize
            hails = @hails.deep_clone
            until hails.empty?
              new_hails = []

              hails.each do |hail|
                if hail[:x_start] == ball[:x_start] && hail[:y_start] == ball[:y_start] && hail[:z_start] == ball[:z_start]
                  logger.warn { "Hit hail: #{hail[:id]}" }
                elsif missed_hail?(ball, hail)
                  logger.warn "Missed ball"
                  logger.warn "BALL: #{ball}"
                  logger.warn "HAIL: #{hail}"
                  return false
                else
                  new_hails << hail
                end
              end

              hails = new_hails
              hails.each { |h| update_hail h }
              update_hail ball
            end
            logger.warn "SUCCESS!!!"
            true
          end

          def missed_hail?(ball, hail)
            (hail[:x_start] > ball[:x_start] && hail[:x_delta] >= ball[:x_delta]) ||
              (hail[:x_start] < ball[:x_start] && hail[:x_delta] <= ball[:x_delta])
          end

          def update_hail(hail)
            hail[:x_start] += hail[:x_delta]
            hail[:y_start] += hail[:y_delta]
            hail[:z_start] += hail[:z_delta]
          end

          def find_start_position # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/MethodLength
            x_sorted = @hails.sort_by { |hail| hail[:x_start] }
            x_ranges = []
            (1...x_sorted.length).each do |index|
              before = x_sorted[0...index]
              after = x_sorted[index..]
              # puts before.length
              # puts after.length
              max = before.map { |h| h[:x_delta] }.min - 1
              min = after.map { |h| h[:x_delta] }.max + 1
              # puts "#{min} -> #{max}"
              if before.empty? || after.empty? then die "ERR"
              elsif max > min
                x_ranges << { start: before[-1][:x_start], end: after[0][:x_start], min:, max: }
              end
            end
            x_ranges << { start: 0, end: x_sorted[0][:x_start], min: x_sorted.map { |h| h[:x_delta] }.max, max: nil }
            x_ranges << { start: x_sorted[-1][:x_start], end: x_sorted[-1][:x_start] * 2, min: nil, max: x_sorted.map { |h| h[:x_delta] }.min }
            puts "X RANGES:"
            puts x_ranges

            y_sorted = @hails.sort_by { |hail| hail[:y_start] }
            y_ranges = []
            (1...y_sorted.length).each do |index|
              before = y_sorted[0...index]
              after = y_sorted[index..]
              max = before.map { |h| h[:y_delta] }.min - 1
              min = after.map { |h| h[:y_delta] }.max + 1
              if before.empty? || after.empty? then die "ERR"
              elsif max > min
                y_ranges << { start: before[-1][:y_start], end: after[0][:y_start], min:, max: }
              end
            end
            y_ranges << { start: 0, end: y_sorted[0][:y_start], min: y_sorted.map { |h| h[:y_delta] }.max, max: nil }
            y_ranges << { start: y_sorted[-1][:y_start], end: nil, min: nil, max: y_sorted.map { |h| h[:y_delta] }.min }
            puts "Y RANGES:"
            puts y_ranges

            z_sorted = @hails.sort_by { |hail| hail[:z_start] }
            z_ranges = []
            (1...z_sorted.length).each do |index|
              before = z_sorted[0...index]
              after = z_sorted[index..]
              max = before.map { |h| h[:z_delta] }.min - 1
              min = after.map { |h| h[:z_delta] }.max + 1
              if before.empty? || after.empty? then die "ERR"
              elsif max > min
                z_ranges << { start: before[-1][:z_start], end: after[0][:z_start], min:, max: }
              end
            end
            z_ranges << { start: 0, end: z_sorted[0][:z_start], min: z_sorted.map { |h| h[:z_delta] }.max, max: nil }
            z_ranges << { start: z_sorted[-1][:z_start], end: nil, min: nil, max: z_sorted.map { |h| h[:z_delta] }.min }
            puts "Z RANGES:"
            puts z_ranges

            x_ranges.each do |x_range|
              puts x_range.inspect
              (x_range[:start].to_i..x_range[:end]).each do |x|
                # puts "x: #{x}"
              end
            end
          end

          def find_first_hailstone # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            firsts = {}

            x_sorted = @hails.sort_by { |hail| hail[:x_start] }
            x_smallest = x_sorted.select { |hail| hail[:x_delta].negative? }.first
            x_largest = x_sorted.select { |hail| hail[:x_delta].positive? }.last
            puts "X smallest: #{x_smallest[:id]}"
            puts "X largest: #{x_largest[:id]}"

            y_sorted = @hails.sort_by { |hail| hail[:y_start] }
            y_smallest = y_sorted.select { |hail| hail[:y_delta].negative? }.first
            y_largest = y_sorted.select { |hail| hail[:y_delta].positive? }.last
            puts "Y smallest: #{y_smallest[:id]}"
            puts "Y largest: #{y_largest[:id]}"

            z_sorted = @hails.sort_by { |hail| hail[:z_start] }
            z_smallest = z_sorted.select { |hail| hail[:z_delta].negative? }.first
            z_largest = z_sorted.select { |hail| hail[:z_delta].positive? }.last || { id: "N/A" }
            puts "Z smallest: #{z_smallest[:id]}"
            puts "Z largest: #{z_largest[:id]}"

            [x_smallest, x_largest, y_smallest, y_largest, z_smallest, z_largest].each do |hail|
              firsts[hail[:id]] ||= 0
              firsts[hail[:id]] += 1
            end
            firsts.select! { |_k, v| v > 1 }
            die "Invalid assumptions" if firsts.length != 1

            @first_hail_id = firsts.keys.first
            @first_hail = @hails[@first_hail_id]
            logger.warn "FIRST HAIL: #{@first_hail_id} #{@first_hail}"

            @ball_speeds = {}
            # Now find the max speeds
            if @first_hail_id == x_smallest[:id]
              @ball_speeds[:x_min] = @hails.map { |hail| hail[:x_delta] }.max
            elsif @first_hail_id == x_largest[:id]
              @ball_speeds[:x_max] = @hails.map { |hail| hail[:x_delta] }.min
            else
              below = @hails.select { |hail| hail[:x_start] < @first_hail[:x_start] }
              above = @hails.select { |hail| hail[:x_start] > @first_hail[:x_start] }
              @ball_speeds[:x_max] = below.map { |h| h[:x_delta] }.min
              @ball_speeds[:x_min] = above.map { |h| h[:x_delta] }.max
            end
            if @first_hail_id == y_smallest[:id]
              @ball_speeds[:y_min] = @hails.map { |hail| hail[:y_delta] }.max
            elsif @first_hail_id == y_largest[:id]
              @ball_speeds[:y_max] = @hails.map { |hail| hail[:y_delta] }.min
            end
            if @first_hail_id == z_smallest[:id]
              @ball_speeds[:z_min] = @hails.map { |hail| hail[:z_delta] }.max
            elsif @first_hail_id == z_largest[:id]
              @ball_speeds[:z_max] = @hails.map { |hail| hail[:z_delta] }.min
            end
            puts @ball_speeds
          end
        end
      end
    end
  end
end

# S two: too hight: 1036586928612806 using (FIRST HAIL: 251 {:id=>251, :x_start=>270625496415908.0, :y_start=>369924714333408.0, :z_start=>396036717863490.0})

# find a line intersecting 3 non-parallel lines in 3 dimensions
