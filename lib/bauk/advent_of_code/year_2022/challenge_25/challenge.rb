# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge25
        # Challenge for 2022/25
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            total = 0
            @lines.each do |line|
              i = snafu_to_i(line)
              logger.info "#{line} => #{i} => #{i_to_snafu(i)}"
              total += i
            end
            total_snafu = i_to_snafu(total)
            logger.warn "Total: #{total} => #{total_snafu} => #{snafu_to_i(total_snafu)}"
          end

          def snafu_to_i(snafu)
            integer = 0
            snafu.reverse.chars.each_with_index do |identifier, index|
              modifier = case identifier
                         when "1" then 1
              when "2" then 2
              when "0" then 0
              when "-" then -1
              when "=" then -2
              else die "Invalid snafu identifier: #{identifier}"
              end
            integer += modifier * 5**index
            end
            integer
          end

          def i_to_snafu(integer)
            snafu = []
            while integer.positive?
              remainder = integer % 5
              integer /= 5
              snafu << remainder
            end
            snafu.each_with_index do |number, index|
              next unless number >= 3

              snafu[index+1] ||= 0
              snafu[index+1] += 1
              snafu[index] -= 5
            end
            snafu.map! { |n| case n; when -1 then "-"; when -2 then "="; else n; end}
            snafu.reverse.join()
          end
        end
      end
    end
  end
end

class Integer
  def to_snafu
    "A"
  end
end
