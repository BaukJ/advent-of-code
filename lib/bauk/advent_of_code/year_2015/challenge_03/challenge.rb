# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge03
        # Challenge for 2015/03
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
            map = Map.new 1, 2
            map.infinite = true
            santa = map.add_character "santa", 0, 0
            santa.cell[0] += 1
            puts map.to_s_with_border
            sleep 1
            @lines[0].chars.each do |c|
              case c
              when ">" then santa.move(0, 1)
              when "<" then santa.move(0, -1)
              when "^" then santa.move(-1, 0)
              when "v" then santa.move(1, 0)
              else raise "Oh no #{c}"
              end
              santa.cell[0] += 1
              puts "#{c} [#{santa.row}/#{santa.column}]"
              if Opts.show
                puts map.to_s_with_border
                sleep 1
              end
            end
            total = 0
            map.cells.each do |cell|
              total += 1 if (cell[0]).positive?
            end
            logger.warn "Star one answer: #{total}"
          end

          def star_two
            map = Map.new 1, 2
            map.infinite = true
            characters = [
              map.add_character("santa", 0, 0),
              map.add_character("robo", 0, 0)
            ]
            index = 0
            characters[index].cell[0] += 2
            puts map.to_s_with_border
            sleep Opts.sleep
            @lines[0].chars.each do |c|
              case c
              when ">" then characters[index].move(0, 1)
              when "<" then characters[index].move(0, -1)
              when "^" then characters[index].move(-1, 0)
              when "v" then characters[index].move(1, 0)
              else raise "Oh no #{c}"
              end
              characters[index].cell[0] += 1
              puts "#{c} [#{characters[index].row}/#{characters[index].column}]"
              if Opts.show
                puts map.to_s_with_border
                sleep Opts.sleep
              end
              index += 1
              index %= 2
            end
            total = 0
            map.cells.each do |cell|
              total += 1 if cell[0].positive?
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
