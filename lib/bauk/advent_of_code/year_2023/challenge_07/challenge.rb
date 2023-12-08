# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge07
        # Challenge for 2023/07
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @hand_size = @lines[0].split[0].length
            @hands = []
            @jokers = true
            parse
          end

          def sort_hands(x, y)
            if x[:type] == y[:type]
              return x[:card_values] <=> y[:card_values] if x[:card_values] != y[:card_values]

              die "Could not seperate hands: #{x.inspect} #{y.inspect}"
            else
              x[:type] <=> y[:type]
            end
          end

          def card_values(cards)
            cards.map do |card|
              case card
              when /[0-9]/ then card.to_i
              when "T" then 10
              when "J" then @jokers ? 1 : 11
              when "Q" then 12
              when "K" then 13
              when "A" then 14
              else die "ERROR"
              end
            end
          end

          def parse
            @lines.each do |line|
              cards, bid = line.split
              cards = cards.chars
              die "Invalid hand size" if cards.length != @hand_size
              @hands << {
                bid: bid.to_i,
                cards:,
                card_values: card_values(cards),
                map: cards.each_with_object({}) do |c, m| 
                       m[c] ||= 0
                                                         m[c] += 1
                     end
              }
              @hands.each { |h| h[:type] = calculate_type(h) }
            end
          end

          def calculate_type(hand) # rubocop:disable Metrics/AbcSize
            map = hand[:map]
            if @jokers && hand[:map]["J"] && map.length > 1
              jokers = map.delete("J")
              highest_card = map.max_by { |_k, v| v }[0]
              map[highest_card] += jokers
            end
            highest_kind = map.values.max
            unique_cards = map.length
            if unique_cards == 5
              1
            elsif unique_cards == 4
              2
            elsif unique_cards == 3 && highest_kind == 2
              3
            elsif unique_cards == 3 && highest_kind == 3
              4
            elsif unique_cards == 2 && highest_kind == 3
              5
            elsif unique_cards == 2 && highest_kind == 4
              6
            elsif unique_cards == 1 && highest_kind == 5
              7
            else
              die "ERROR"
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            @total = 0
            @hands.sort! do |x, y|
              sort_hands x, y
            end
            @hands.each_with_index do |hand, index|
              @total += hand[:bid] * (index + 1)
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            # @total = 0
            # @jokers = true
            # @hands.sort! do |x, y|
            #   sort_hands x, y
            # end
            # @hands.each_with_index do |hand, index|
            #   @total += hand[:bid] * (index + 1)
            # end
            logger.warn "Star one answer: #{@total}"
          end
        end
      end
    end
  end
end
