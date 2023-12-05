# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge05
        # Challenge for 2022/05
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @move_lines = false
            @stacks = []
            @lines.each do |line|
              if line.empty?
                @move_lines = true
                @stacks.each(&:reverse!)
              elsif @move_lines
                move_line line
              else
                stack_line line
              end
            end
            puts @stacks.inspect
          end

          def stack_line(line)
            chars = line.chars
            index = -1
            until chars.empty?
              index += 1
              @stacks << [] if index >= @stacks.length
              box = chars.shift(4)[1]
              return if box =~ /[0-9]/
              next if box =~ /^ *$/

              @stacks[index] << box
            end
          end

          def move_line(line)
            die "Invalid move line: #{line}" unless line =~ /^move ([0-9]+) from ([0-9]+) to ([0-9]+)$/
            logger.debug "Pre move: #{@stacks.inspect}"
            moving = @stacks[$2.to_i - 1].pop($1.to_i) # .reverse # Difference  between star one and two
            @stacks[$3.to_i - 1] += moving
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            logger.warn "Star one answer: #{@stacks.map { |s| s[-1] }.join}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
