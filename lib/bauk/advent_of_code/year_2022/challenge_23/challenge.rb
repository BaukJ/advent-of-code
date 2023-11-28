# frozen_string_literal: true

require_relative "../../base_challenge"
require_relative "map"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge23
        # Challenge for 2022/23
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.new @lines.length, @lines[0].length
            @lines.each_with_index do |row, row_index|
              row.chars.each_with_index do |item, column_index|
                case item
                when "#" then @map.insert row_index, column_index, "#"
                when "." then nil
                else die "Invalid letter in input map: '#{item}'"
                end
              end
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            rounds
            chomp_map
            puts @map.to_s_with_border
            logger.warn "FINISHED: Round: #{@round}, Size: #{@map.row_count} * #{@map.column_count} = #{@map.row_count * @map.column_count}, Moves: #{@map.moves}"
          end

          def rounds
            @round = 0
            loop do
              upsize_map
              @round += 1
              if Opts.show_map
                puts @map.directions.inspect
                puts @map.to_s_with_border
                sleep 1
              end
              @map.plan!
              new_map = @map.update
              new_map.rotate_directions
              @map = new_map
              logger.info "Round: #{@round}, Size: #{@map.row_count} * #{@map.column_count}, Moves: #{@map.moves}"
              return if @map.moves.zero? || (!Opts.rounds.zero? && @round >= Opts.rounds)
            end
          end

          def upsize_map
            @map.insert_row(0) if @map.row(0).flatten.any?
            @map.insert_row(-1) if @map.row(-1).flatten.any?
            @map.insert_column(0) if @map.column(0).flatten.any?
            @map.insert_column(-1) if @map.column(-1).flatten.any?
          end

          def chomp_map
            loop do
              if @map.row(0).flatten.none?
                @map.delete_row(0)
              elsif @map.row(-1).flatten.none?
                @map.delete_row(-1)
              elsif @map.column(0).flatten.none?
                @map.delete_column(0)
              elsif @map.column(-1).flatten.none?
                @map.delete_column(-1)
              else
                break
              end
            end
          end
        end
      end
    end
  end
end
