# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge07
        # Challenge for 2015/07
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

          def parse_wires
            wires = {}
            @lines.each do |line|
              case line
              when /^([0-9]+) -> ([a-z]+)/ then wires[$2] = { value: $1.to_i }
              when /^([a-z]+) -> ([a-z]+)/ then wires[$2] = { wire: $1 }
              when /^NOT ([a-z]+) -> ([a-z]+)$/ then wires[$2] = { not: $1 }
              when /^([a-z]+) OR ([a-z]+) -> ([a-z]+)$/ then wires[$3] = { or: [$1, $2] }
              when /^([a-z]+) AND ([a-z]+) -> ([a-z]+)$/ then wires[$3] = { and: [$1, $2] }
              when /^([0-9]+) AND ([a-z]+) -> ([a-z]+)$/
                wires["static_#{$1}"] = { value: $1.to_i }
                wires[$3] = { and: ["static_#{$1}", $2] }
              when /^([a-z]+) RSHIFT ([0-9]+) -> ([a-z]+)$/ then wires[$3] = { rshift: [$1, $2.to_i] }
              when /^([a-z]+) LSHIFT ([0-9]+) -> ([a-z]+)$/ then wires[$3] = { lshift: [$1, $2.to_i] }
              else raise "Oh no: #{line}"
              end
            end
            @wires = wires
          end

          def star_one
            parse_wires
            run_wires
            # logger.debug "a = #{wires["a"]}"
            # wires.keys.sort.each do |key|
            #   puts "#{key}: #{wires[key][:value]}"
            # end
            logger.warn "Star one answer: #{@wires["a"][:value]}"
            @ans = @wires["a"][:value]
          end

          def star_two
            parse_wires
            @wires["b"][:value] = @ans
            run_wires
            logger.warn "Star two answer: #{@wires["a"][:value]}"
          end

          def run_wires
            loop do
              updated = 0
              missing = 0
              @wires.each do |_name, wire|
                next if wire[:value]

                missing += 1
                if wire[:wire] && @wires[wire[:wire]][:value]
                  wire[:value] = @wires[wire[:wire]][:value]
                elsif wire[:not] && @wires[wire[:not]][:value]
                  wire[:value] = ~ @wires[wire[:not]][:value]
                  wire[:value] = (wire[:value] % 65_535) + 1
                  logger.debug "NOT #{@wires[wire[:not]][:value]} -> #{wire[:value]}"
                elsif wire[:and] && @wires[wire[:and][0]][:value] && @wires[wire[:and][1]][:value]
                  wire[:value] = @wires[wire[:and][0]][:value] & @wires[wire[:and][1]][:value]
                  logger.debug "#{@wires[wire[:and][0]][:value]} & #{@wires[wire[:and][1]][:value]} -> #{wire[:value]}"
                elsif wire[:or] && @wires[wire[:or][0]][:value] && @wires[wire[:or][1]][:value]
                  wire[:value] = @wires[wire[:or][0]][:value] | @wires[wire[:or][1]][:value]
                elsif wire[:lshift] && @wires[wire[:lshift][0]][:value]
                  wire[:value] = @wires[wire[:lshift][0]][:value] << wire[:lshift][1]
                elsif wire[:rshift] && @wires[wire[:rshift][0]][:value]
                  wire[:value] = @wires[wire[:rshift][0]][:value] >> wire[:rshift][1]
                else
                  next
                end
                updated += 1
              end
              logger.info "Missing: #{missing}, Updated: #{updated}"
              break if updated.zero?
            end
          end
        end
      end
    end
  end
end
