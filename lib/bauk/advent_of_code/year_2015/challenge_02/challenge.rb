# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge02
        # Challenge for 2015/02
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @boxes = @lines.map do |line|
              dimensions = line.split("x").map(&:to_i)
              {
                h: dimensions[0],
                w: dimensions[1],
                l: dimensions[2]
              }
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            @total = 0
            @boxes.each do |box|
              hw = box[:h] * box[:w]
              hl = box[:h] * box[:l]
              wl = box[:w] * box[:l]
              @total += (2 * hw) + (2 * hl) + (2 * wl) + [hw, hl, wl].min
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            @total = 0
            @boxes.each do |box|
              sides = [box[:h], box[:w], box[:l]].sort
              @total += (sides[0] * 2) + (sides[1] * 2)
              @total += sides.inject(1) { |o, s| o * s }
            end
            logger.warn "Star two answer: #{@total}"
          end
        end
      end
    end
  end
end
