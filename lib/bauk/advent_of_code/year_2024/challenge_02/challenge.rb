# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge02
        # Challenge for 2024/02
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one if [0, 1].include? Opts.star
            star_two if [0, 2].include? Opts.star
          end

          def is_safe?(nums)
            increasing = 0
            decreasing = 0
            unsafe = 0
            previous_num = nums.shift
            nums.each do |num|
              diff = num - previous_num
              if diff.zero? || diff > 3 || diff < -3
                unsafe += 1
                next
              elsif diff.negative?
                decreasing += 1
              elsif diff.positive?
                increasing += 1
              end
              previous_num = num
            end
            unsafe += [increasing, decreasing].min
            unsafe.zero?
          end

          def star_one
            total = 0
            @lines.each do |line|
              nums = line.split.map(&:to_i)
              if is_safe? nums.clone
                # puts "SAFE: #{nums}"
                total += 1
              end
            end
            logger.warn "Star one answer: #{total}"
          end

          # >268 <280
          def star_two
            total = 0
            @lines.each do |line|
              nums = line.split.map(&:to_i)
              if is_safe? nums.clone
                total += 1
                next
              end
              (0...nums.length).each do |i|
                next unless is_safe? nums[0...i] + nums[(i + 1)..]

                total += 1
                puts "#{nums} => remove #{i}"
                break
              end
              # puts nums.to_s
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
