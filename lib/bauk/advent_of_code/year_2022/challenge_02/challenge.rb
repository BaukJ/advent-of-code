# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge02
        # Challenge for 2022/2
        class Challenge < BaseChallenge
          def run
            lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @total = 0
            lines.each do |line|
              items = line.split(/ */)
              die "Wrong number of items! (#{items.inspect})" unless items.length == 2
              @total += calculate_score(*items)
            end
            logger.warn "Part one: #{@total}"
          end

          def calculate_score(their, our)
            die "Invalid opponent option: [#{their}]" unless %w[A B C].include? their
            case their
            when "A" then calculate_rock(our)
            when "B" then calculate_paper(our)
            when "C" then calculate_scissors(our)
            end
          end

          def calculate_rock(our)
            case our
            when "X" then 1 + 3
            when "Y" then 2 + 6
            when "Z" then 3 + 0
            end
          end

          def calculate_paper(our)
            case our
            when "X" then 1 + 0
            when "Y" then 2 + 3
            when "Z" then 3 + 6
            end
          end

          def calculate_scissors(our)
            case our
            when "X" then 1 + 6
            when "Y" then 2 + 0
            when "Z" then 3 + 3
            end
          end
        end
      end
    end
  end
end
