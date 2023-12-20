# frozen_string_literal: true
# s1 too high 908202812

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge20
        # Challenge for 2023/20
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @modules = {
              button: {dests: [:broadcaster], type: :b}
            }
            inputs_map = {}
            @lines.each do |line|
              die line unless line =~ /^([&%]?)([a-z]+) -> ([a-z, ]+)$/
              type = $1
              name = $2.to_sym
              dests = $3.split(", ").map(&:to_sym)
              dests.each do |dest|
                inputs_map[dest] ||= {}
                inputs_map[dest][name] = false
              end
              if name == :broadcaster
                @modules[name] = {dests:, type: :b}
              elsif type == "%"
                @modules[name] = {dests:, on: false, type: :f}
              elsif type == "&"
                @modules[name] = {dests:, type: :c}
              end
            end
            @modules.each do |name, mod|
              mod[:inputs] = inputs_map[name] if mod[:type] == :c
            end
            puts @modules.inspect
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def count_pulses
            pulses = [{high: false, dest: :broadcaster, source: :button}]
            high_count = 0
            low_count = 0
            logger.debug { "" }
            until pulses.empty?
              new_pulses = []
              high_count += pulses.select { |p| p[:high] }.length
              low_count += pulses.reject { |p| p[:high] }.length
              pulses.each do |pulse|
                logger.debug { "#{pulse[:source]} -#{pulse[:high] ? "high" : "low"}-> #{pulse[:dest]}" }
                mod = @modules[pulse[:dest]]
                next unless mod

                case mod[:type]
                when :b
                  new_pulses += mod[:dests].map { |d| {source: pulse[:dest], dest: d, high: pulse[:high]}}
                when :f
                  new_pulses += calculate_f_pulses(mod, pulse)
                when :c
                  new_pulses += calculate_c_pulses(mod, pulse)
                else die
                end
              end
              pulses = new_pulses
            end
            [low_count, high_count]
          end

          def calculate_f_pulses(mod, pulse)
            return [] if pulse[:high]

            mod[:on] = !mod[:on] # flip
            # puts mod[:on]
            mod[:dests].map { |d| {source: pulse[:dest], dest: d, high: mod[:on] }}
          end

          def calculate_c_pulses(mod, pulse)
            mod[:inputs][pulse[:source]] = pulse[:high]

            # puts "received: #{pulse}| pre: #{mod}"
            high = !mod[:inputs].values.all?
            # puts "received: #{pulse}| post: #{mod}"

            mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: } }
          end

          def star_one
            low_total = 0
            high_total = 0
            1000.times.each do |r|
              counts = count_pulses
              logger.info { "Round #{r} Low/high = #{counts}"}
              low_total += counts[0]
              high_total += counts[1]
            end
            logger.info { "Low: #{low_total} | Hight: #{high_total}" }
            logger.warn "Star one answer: #{low_total*high_total}"
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
