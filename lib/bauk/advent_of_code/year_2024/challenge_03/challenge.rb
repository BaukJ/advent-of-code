# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge03
        # Challenge for 2024/03
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

          def star_one
            total = 0
            @lines.each do |line|
              seq = []
              num1 = ""
              num2 = ""
              line.chars.each do |char|
                if char == "m"
                  seq = ["m"]
                  num1 = ""
                  num2 = ""
                elsif char == "u" && seq == %w[m]
                  seq << char
                elsif char == "l" && seq == %w[m u]
                  seq << char
                elsif char == "(" && seq == %w[m u l]
                  seq << char
                elsif char == "," && seq == %w[m u l (] && num1.length.positive?
                  seq << char
                elsif char == ")" && seq == %w[m u l ( ,] && num1.length.positive? && num2.length.positive?
                  if num1.length <= 3 && num2.length <= 3
                    total += num1.to_i * num2.to_i
                    # puts "#{num1} * #{num2} #{seq}"
                  end
                  seq = []
                elsif char =~ /[0-9]/ && seq == %w[m u l (]
                  num1 += char
                elsif char =~ /[0-9]/ && seq == %w[m u l ( ,]
                  num2 += char
                else
                  seq = []
                end
                # puts "#{seq}"
              end
            end
            logger.warn "Star one answer: #{total}"
          end

          def star_two # < 97977612
            total = 0
            do_it = true
            @lines.each do |line|
              seq = []
              num1 = ""
              num2 = ""
              line.chars.each do |char|
                if char == "m"
                  seq = ["m"]
                  num1 = ""
                  num2 = ""
                elsif char == ")" && seq == %w[m u l ( ,] && num1.length.positive? && num2.length.positive?
                  puts "#{seq.join}) #{num1} * #{num2} #{do_it}"
                  total += num1.to_i * num2.to_i if do_it && num1.length <= 3 && num2.length <= 3
                  seq = []
                elsif char =~ /[0-9]/ && seq == %w[m u l (]
                  num1 += char
                elsif char =~ /[0-9]/ && seq == %w[m u l ( ,]
                  num2 += char
                elsif char == "d"
                  seq = ["d"]
                elsif (char == "o" && seq == %w[d]) ||
                      (char == "n" && seq == %w[d o]) ||
                      (char == "'" && seq == %w[d o n]) ||
                      (char == "t" && seq == %w[d o n ']) ||
                      (char == "(" && [%w[d o], %w[d o n ' t]].include?(seq)) ||
                      # Mul
                      (char == "u" && seq == %w[m]) ||
                      (char == "l" && seq == %w[m u]) ||
                      (char == "(" && seq == %w[m u l]) ||
                      (char == "," && seq == %w[m u l (] && num1.length.positive?)
                  seq << char
                elsif char == ")" && seq == %w[d o (]
                  puts "#{seq.join})"
                  do_it = true
                  seq = []
                elsif char == ")" && seq == %w[d o n ' t (]
                  puts "#{seq.join})"
                  do_it = false
                  seq = []
                else
                  seq = []
                end
                # puts "#{seq} #{do_it}" if seq[0] == "d" && seq[1] == "o"
              end
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
