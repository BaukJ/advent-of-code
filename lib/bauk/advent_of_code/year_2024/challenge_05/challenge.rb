# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2024
      module Challenge05
        # Challenge for 2024/05
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @rules = {}
            @prints = []
            @lines.each do |line|
              if line =~ /^([0-9]+)\|([0-9]+)$/
                @rules[$1.to_i] ||= []
                @rules[$1.to_i] << $2.to_i
              elsif line =~ /^[0-9]+,[0-9,]+/
                @prints << line.split(",").map(&:to_i)
              elsif line != ""
                raise "Oh no!"
              end
            end
            puts @rules
            puts "prints: #{@prints}"
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one # <8302 >2668
            total = 0
            middles = {}
            @invalid_prints = []
            @prints.each do |pages|
              valid = true
              pages.each_with_index do |page, i|
                # If previous pages include the next rule, it's bad...
                next unless @rules.key?(page)

                for check_page in @rules[page]
                  if pages[0..i].include? check_page
                    valid = false
                    break
                  end
                end
              end
              if valid
                middle = pages[(pages.length - 1) / 2]
                total += middle
                middles[middle] = true
              else
                @invalid_prints << pages
              end
            end
            logger.warn "Star one answer: #{total} or #{middles.keys.sum}"
          end

          def star_two
            total = 0
            @invalid_prints.each do |pages|
              # Reverse the pages so we can push back "smaller" numbers
              reversed = pages.reverse
              new_list = []

              until reversed.empty?
                page = reversed.shift

                correct = true
                if @rules.key?(page)
                  @rules[page].each do |check_page|
                    if reversed.include? check_page
                      correct = false
                      break
                    end
                  end
                end
                if correct
                  new_list << page
                else
                  # Push it back one time
                  reversed << page
                end
              end
              total += new_list[(new_list.length - 1) / 2]
            end
            logger.warn "Star two answer: #{total}"
          end
        end
      end
    end
  end
end
