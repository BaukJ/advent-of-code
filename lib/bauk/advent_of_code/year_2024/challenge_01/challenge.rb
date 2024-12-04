# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge01
        # Challenge for 2024/01
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
            puts @lines
            @list1 = []
            @list2 = []
            @lines.each do |line|
              numbers = line.split("   ")
              @list1 << numbers[0].to_i
              @list2 << numbers[1].to_i
            end
            @list1.sort!
            @list2.sort!
            # puts "List 1: #{@list1}"
            # puts "List 2: #{@list2}"
            total = 0
            @list2.length.times do |i|
              n1 = @list1[i]
              n2 = @list2[i]
              difference = (n2 - n1).abs
              # puts "#{n1} => #{n2} = #{difference}"
              total += difference
            end
            logger.warn "Star one answer: #{total}"
          end

          def star_two
            total = 0
            @list1.each do |n1|
              count = 0
              @list2.each do |n2|
                count += 1 if n1 == n2
              end
              diff = n1 * count
              puts "#{n1} appears #{count} times => #{diff}"
              total += diff
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
