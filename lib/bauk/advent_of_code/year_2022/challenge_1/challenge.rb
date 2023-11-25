# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge1
        # Challenge for 2022/1
        class Challenge < BaseChallenge
          def run
            list = File.readlines File.join(__dir__, Opts.file)
            parse_list list
            logger.warn "Callories for top elf: #{@elves.max}"
            top_3 = @elves.sort[-3..-1].inject(0) { |o, e| o + e }
            logger.warn "Callories for top 3 elves: #{top_3}"
          end

          def parse_list(list)
            @elves = []
            elf = 0
            list.map(&:chomp).each do |line|
              logger.debug line
              if line.empty?
                logger.info "Elf total: #{elf}"
                @elves << elf if elf
                elf = 0
              else
                elf += line.to_i
              end
            end
            @elves << elf
          end
        end
      end
    end
  end
end
