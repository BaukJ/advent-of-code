# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge01
        # Challenge for 2015/01
        class Challenge < BaseChallenge
          def initialize
            super
            @line = File.read File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            floor = 0
            @line.chars.each do |char|
              logger.debug { "Start: #{floor}"}
              case char
              when ")" then floor -= 1
              when "(" then floor += 1
              else die "Invalid char: #{char}"
              end
              logger.debug { "End: #{floor} (after '#{char}')"}
              sleep 0.5 if logger.debug?
            end
            logger.warn "Star one answer: #{floor}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
