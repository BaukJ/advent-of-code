# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge03
        # Challenge for 2022/3
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @scores = [*("a".."z"), *("A".."Z")].map.with_index { |l, i| [l, i + 1] }.to_h
            @commons = Hash.new 0
          end

          def run
            parse_lines
            logger.info @commons
            calculate_score
            logger.warn "Total score: #{@score}"
          end

          def calculate_score
            @score = 0
            @commons.each do |letter, count|
              @score += count * @scores[letter]
            end
          end

          def parse_lines
            @lines.each do |line|
              midpoint = line.length / 2
              list_a = line[0..midpoint - 1]
              list_b = line[midpoint..]
              common_item = get_common_item list_a.chars, list_b.chars
              logger.info do
                "#{line}(#{line.length}) -> #{list_a}(#{list_a.length}) / #{list_b}(#{list_b.length}) -> #{common_item}"
              end
              @commons[common_item] += 1
            end
          end

          def get_common_item(list_a, list_b)
            common = nil
            list_a.uniq.each do |item|
              if list_b.include? item
                if common.nil?
                  common = item
                elsif common != item
                  die "Two overlapping items found #{common} and #{item} in #{list_a}/#{list_b}"
                end
              end
            end
            die "No common item found in #{list_a}/#{list_b}" unless common
            common
          end
        end
      end
    end
  end
end
