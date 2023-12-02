# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge02
        # Challenge for 2023/02
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @maxes = {
              "red" => 12,
              "green" => 13,
              "blue" => 14
            }
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            game = 0
            games_possible = []
            @lines.each do |line|
              game += 1
              die "Invalid line" unless line.sub! "Game #{game}: ", ""
              possible = true
              line.split(/; */).each do |go|
                go.split(/, */).each do |get|
                  die "Invalid get: #{get}" unless get =~ /^([0-9]+) ([a-z]*)$/
                  die "Invalid colour: '#{$2}'" unless @maxes[$2]
                  possible = false if $1.to_i > @maxes[$2]
                end
              end
              games_possible << game if possible
              logger.debug line
            end
            logger.debug "Possible games: #{games_possible.inspect}"
            logger.warn "Star one answer: #{games_possible.sum}"
          end

          def star_two
            game = 0
            total = 0
            @lines.each do |line|
              game += 1
              mins = {"blue" => 0, "green" => 0, "red" => 0}
              line.split(/; */).each do |go|
                go.split(/, */).each do |get|
                  die "Invalid get: #{get}" unless get =~ /^([0-9]+) ([a-z]*)$/
                  die "Invalid colour: '#{$2}'" unless @maxes[$2]
                  mins[$2] ||= 0
                  mins[$2] = $1.to_i if $1.to_i > mins[$2]
                end
              end
              total += mins.values.inject(1) { |x,y| x * y }
              logger.debug line
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
