# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge05
        # Challenge for 2015/05
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

          def star_one # >228 <250 <249
            previous_char = ""
            nice = 0
            naughty = 0
            @lines.each do |line|
              vowels = 0
              duplicates = 0
              forbidden = 0
              line.chars.each do |char|
                vowels += 1 if %w[a e i o u].include? char
                duplicates += 1 if char == previous_char
                forbidden += 1 if %w[ab cd pq xy].include? "#{previous_char}#{char}"
                previous_char = char
              end
              nice += 1 if vowels >= 3 && duplicates > 0 && forbidden == 0
              naughty += 1 unless vowels >= 3 && duplicates > 0 && forbidden == 0
              puts "#{line}  #{vowels} vowels, #{duplicates} duplicated #{forbidden} forbidden => #{vowels >= 3 && duplicates > 0 && forbidden == 0}"
            end
            logger.warn "Star one answer: #{nice} / #{naughty}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
