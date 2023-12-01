# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge01
        # Challenge for 2023/01
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def star_one
            @total = 0
            @lines.each do |line|
              numbers = line.chars.grep(/[0-9]/)
              # logger.debug numbers[0] + numbers[-1]
              @total += (numbers[0] + numbers[-1]).to_i
            end
            logger.warn "Start 1 answer: #{@total}"
          end

          def star_two
            string_nums = {
              "one" => "1",
              "two" => "2",
              "three" => "3",
              "four" => "4",
              "five" => "5",
              "six" => "6",
              "seven" => "7",
              "eight" => "8",
              "nine" => "9"
            }

            @total = 0
            @lines.each do |line|
              numbers = []
              snum = ""
              line.chars.each do |char|
                if char =~ /[0-9]/
                  numbers << char
                  snum = ""
                else
                  snum += char
                end
                string_nums.each do |string, num|
                  next unless snum =~ /#{string}/

                  # Numbers can overlap! twone
                  snum = snum[1..] while snum =~ /#{string}/
                  numbers << num
                end
              end
              line_num = (numbers[0] + numbers[-1]).to_i
              logger.debug "#{line} => #{numbers} => #{line_num}"
              @total += line_num
            end
            logger.warn "Start 1 answer: #{@total}"
          end
        end
      end
    end
  end
end
