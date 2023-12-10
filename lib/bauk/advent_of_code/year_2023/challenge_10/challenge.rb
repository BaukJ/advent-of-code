# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge10
        # Challenge for 2023/10
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            puts @map
            @loop = {}
            @map.cells_with_row_column.each do |cell, row, column|
              next unless cell != [] && cell[:char] == "S"

              die "Too many S's!" unless @loop.empty?
              @start_cell = {row:, column:}
            end
            logger.warn "Start cell: #{@start_cell.inspect}"
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one # rubocop:disable Metrics/AbcSize
            @ends = [@start_cell]
            until @ends.empty?
              new_ends = []
              @ends.each do |e|
                logger.debug "ENDS: #{@ends.inspect}"
                if @loop["#{e[:row]}_#{e[:column]}"]
                  logger.debug "Connected loop!"
                  next
                end
                @loop["#{e[:row]}_#{e[:column]}"] = e
                cell = @map.cell e[:row], e[:column]
                cell[:connections].each do |connection|
                  connected_cell = @map.cell connection[:row], connection[:column]
                  next if connected_cell.empty?

                  new_ends << connection if connected_cell[:connections].include? e
                end
              end
              @ends = new_ends
            end
            @loop.each_value do |cell|
              @map.cell(cell[:row], cell[:column])[:char] = "#"
            end
            puts @map
            logger.warn "Star one answer: #{@loop.length / 2}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
