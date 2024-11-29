# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge06
        # Challenge for 2015/06
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

          def star_one_old
            map = Map.new 1000, 1000
            map.cells.each { |c| c << false }
            @lines.each do |line|
              raise "Oh no" unless line =~ /(toggle|turn on|turn off) ([0-9]*),([0-9]*) through ([0-9]*),([0-9]*)/

              pointa = { row: $2.to_i, column: $3.to_i }
              pointb = { row: $4.to_i, column: $5.to_i }
              cells = map.cells_inside(pointa, pointb)
              case $1
              when "toggle" then cells.each { |c| c[0] = !c[0] }
              when "turn on" then cells.each { |c| c[0] = true }
              when "turn off" then cells.each { |c| c[0] = false }
              end
              total = 0
              map.cells.each { |c| total += 1 if c[0] }
              puts line
              puts total
              # puts map.to_s_with_border
              # sleep 5
            end
            logger.warn "Star one answer: "
          end

          def star_one
            map = []
            total = 0
            1000.times do
              row = []
              1000.times do
                row << false
              end
              map << row
            end
            @lines.each do |line|
              raise "Oh no" unless line =~ /(toggle|turn on|turn off) ([0-9]*),([0-9]*) through ([0-9]*),([0-9]*)/

              pointa = { row: $2.to_i, column: $3.to_i }
              pointb = { row: $4.to_i, column: $5.to_i }
              row_min = [pointa[:row], pointb[:row]].min
              row_max = [pointa[:row], pointb[:row]].max
              column_min = [pointa[:column], pointb[:column]].min
              column_max = [pointa[:column], pointb[:column]].max
              (row_min..row_max).each do |r|
                (column_min..column_max).each do |c|
                  case $1
                  when "toggle" then map[r][c] = !map[r][c]
                  when "turn on" then map[r][c] = true
                  when "turn off" then map[r][c] = false
                  end
                end
              end
              total = 0
              map.each do |row|
                row.each do |cell|
                  total += 1 if cell
                end
              end
              puts line
              puts total
            end
            logger.warn "Star one answer: #{total}"
          end

          def star_two
            map = []
            total = 0
            1000.times do
              row = []
              1000.times do
                row << 0
              end
              map << row
            end
            @lines.each do |line|
              raise "Oh no" unless line =~ /(toggle|turn on|turn off) ([0-9]*),([0-9]*) through ([0-9]*),([0-9]*)/

              pointa = { row: $2.to_i, column: $3.to_i }
              pointb = { row: $4.to_i, column: $5.to_i }
              row_min = [pointa[:row], pointb[:row]].min
              row_max = [pointa[:row], pointb[:row]].max
              column_min = [pointa[:column], pointb[:column]].min
              column_max = [pointa[:column], pointb[:column]].max
              (row_min..row_max).each do |r|
                (column_min..column_max).each do |c|
                  case $1
                  when "toggle" then map[r][c] += 2
                  when "turn on" then map[r][c] += 1
                  when "turn off" then map[r][c] -= 1 unless map[r][c].zero?
                  end
                end
              end
              total = 0
              map.each do |row|
                row.each do |cell|
                  total += cell
                end
              end
              puts line
              puts total
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
