# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge06
        # Challenge for 2023/06
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @races = []
            @lines[0].sub(/Time: */, "").split(/  */).each_with_index do |time, index|
              @races << {}
              @races[index][:time] = time.to_i
            end
            @lines[1].sub(/Distance: */, "").split(/  */).each_with_index do |distance, index|
              @races[index][:distance] = distance.to_i
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def get_possible_wins(race)
            possible_wins = 0
            (0..race[:time]).each do |hold|
              speed = hold
              distance = (race[:time] - hold) * speed
              possible_wins += 1 if distance > race[:distance]
            end
            possible_wins
          end

          def star_one
            @races.each do |race|
              race[:wins] = get_possible_wins race
            end
            logger.warn "Star one answer: #{@races.inject(1) { |o, r| o * r[:wins]}}"
          end

          def star_two
            race = {
              time: @lines[0].sub(/Time: */, "").gsub(" ", "").to_i,
              distance: @lines[1].sub(/Distance: */, "").gsub(" ", "").to_i
            }
            logger.warn "Star two answer: #{get_possible_wins(race)}"
          end
        end
      end
    end
  end
end
