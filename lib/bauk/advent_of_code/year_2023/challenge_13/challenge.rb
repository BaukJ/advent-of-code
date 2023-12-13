# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge13
        # Challenge for 2023/13
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            lines = []
            @maps = []
            @lines.each do |line|
              if line.empty?
                @maps << Map.from_lines(lines)
                lines = []
              else
                lines << line
              end
            end
            @maps << Map.from_lines(lines)
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def find_symmetry_index(lines, smudge = false)
            indexes = (0..(lines[0].length - 2)).to_a
            # puts max_right
            indexes.select! do |index|
              valid_index? lines, index, smudge
            end
            die "Found #{indexes.length} mirror points: #{indexes}" if indexes.length > 1
            logger.info "Found index #{indexes}"
            indexes
          end

          def valid_index?(lines, index, smudge)
            lines.each_with_index do |line, line_index|
              left = index.clone
              right = index + 1
              # puts "I: #{index}"
              while left >= 0 && right < lines[0].length
                # puts "Index: #{index}) left) #{left}) #{line[left][0]} != #{line[right][0]}"
                if line[left] != line[right]
                  return false unless smudge

                  lines2 = lines.map(&:clone)
                  lines2[line_index][left] = !lines2[line_index][left]
                  return true if valid_index?(lines2, index, false)

                  lines2[line_index][left] = !lines2[line_index][left]
                  lines2[line_index][right] = !lines2[line_index][right]
                  return true if valid_index?(lines2, index, false)
                end

                left -= 1
                right += 1
              end
            end
            !smudge # If we need to smudge, this can't count
          end

          def star_one
            @total = 0
            @maps.each do |map|
              # puts map
              index = find_symmetry_index(map.rows)
              @total += if index.empty?
                          100 * (find_symmetry_index(map.columns)[0] + 1)
                        else
                          (index[0] + 1)
                        end
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            @total = 0
            @maps.each do |map|
              index = find_symmetry_index(map.rows, true)
              @total += if index.empty?
                          100 * (find_symmetry_index(map.columns, true)[0] + 1)
                        else
                          (index[0] + 1)
                        end
            end
            logger.warn "Star two answer: #{@total}"
          end
        end
      end
    end
  end
end
