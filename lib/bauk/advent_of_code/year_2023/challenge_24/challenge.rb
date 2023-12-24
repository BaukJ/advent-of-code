# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge24
        # Challenge for 2023/24
        class Challenge < BaseChallenge
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
              y: ((hail_2[:x]*hail_1[:c]) - (hail_1[:x]*hail_2[:c])) / ((hail_1[:x]*hail_2[:y]) - (hail_2[:x]*hail_1[:y]))
            }
          end

          def find_x_y_intersects
            @x_y_intersects = []
            @hails.each_with_index do |hail_1, index|
              ((index+1)...@hails.length).each do |index_2|
                hail_2 = @hails[index_2]

                next if hail_1[:y][:x] == hail_2[:y][:x] # If they are parallel

                logger.debug { "#{hail_1} + #{hail_2}" }
                intersect = find_x_y_intersect_from_0 hail_1[0], hail_2[0]
                logger.debug { "INTERSECT: #{intersect} "}

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
            find_first_hailstone
            logger.warn "Star two answer: "
          end

          def find_first_hailstone
            x_sorted = @hails.sort { |hail| hail[:x_start] }
            x_smallest = x_sorted.select { |hail| hail[:x_delta].negative? }.first

            puts "#{x_smallest[:id]}"
          end
        end
      end
    end
  end
end
