# frozen_string_literal: true

# s1 too high 908202812

require_relative "../../base_challenge"
require "benchmark"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge20
        # Challenge for 2023/20
        class Challenge < BaseChallenge # rubocop:disable Metrics/ClassLength
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @pattern_length = 10
            @modules = {
              button: { dests: [:broadcaster], type: :b }
            }
            @inputs_map = {}
            @lines.each do |line|
              die line unless line =~ /^([&%]?)([a-z]+) -> ([a-z, ]+)$/
              type = $1
              name = $2.to_sym
              dests = $3.split(", ").map(&:to_sym)
              dests.each do |dest|
                @inputs_map[dest] ||= {}
                @inputs_map[dest][name] = false
              end
              if name == :broadcaster
                @modules[name] = { dests:, type: :b }
              elsif type == "%"
                @modules[name] = { dests:, on: false, type: :f }
              elsif type == "&"
                @modules[name] = { dests:, type: :c }
              end
            end
            @modules.each do |name, mod|
              mod[:inputs] = @inputs_map[name] if mod[:type] == :c
            end
            @reset_modules = JSON.dump(@modules)
          end

          def reset_modules
            @modules = JSON.parse(@reset_modules, symbolize_names: true)
            @modules.each_value do |mod|
              mod[:type] = mod[:type].to_sym
              mod[:dests].map!(&:to_sym)
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def count_pulses
            pulses = [{ high: false, dest: :broadcaster, source: :button }]
            high_count = 0
            low_count = 0
            @rx = 0
            # logger.debug { "" }
            until pulses.empty?
              new_pulses = []
              high_count += pulses.select { |p| p[:high] }.length
              low_count += pulses.reject { |p| p[:high] }.length
              pulses.each do |pulse|
                @rx += 1 if pulse[:dest] == :rx && !pulse[:high]
                mod = @modules[pulse[:dest]]
                # logger.debug { "#{pulse[:source]} -#{pulse[:high] ? "high" : "low"}-> #{pulse[:dest]} (#{mod&.[](:type)})" }
                next unless mod

                case mod[:type]
                when :b
                  new_pulses += mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: pulse[:high] } }
                when :f
                  new_pulses += calculate_f_pulses(mod, pulse)
                when :c
                  new_pulses += calculate_c_pulses(mod, pulse)
                else die mod
                end
              end
              pulses = new_pulses
            end
            [low_count, high_count]
          end

          def do_pulses # rubocop:disable Metrics/AbcSize
            pulses = [{ high: false, dest: :broadcaster, source: :button }]
            # @initial_pulses ||= @modules[:broadcaster][:dests].map { |d| {source: :broadcaster, dest: d, high: false}}
            # pulses = @initial_pulses
            @rx = 0
            until pulses.empty?
              new_pulses = []
              pulses.each do |pulse|
                # puts pulse
                @rx += 1 if pulse[:dest] == :rx && !pulse[:high]
                mod = @modules[pulse[:dest]]
                next unless mod

                case mod[:type]
                when :b
                  new_pulses += mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: pulse[:high] } }
                when :f
                  new_pulses += calculate_f_pulses(mod, pulse)
                when :c
                  new_pulses += calculate_c_pulses(mod, pulse)
                else die mod
                end
              end
              pulses = new_pulses
            end
          end

          def calculate_f_pulses(mod, pulse)
            return [] if pulse[:high]

            mod[:on] = !mod[:on] # flip
            # puts mod[:on]
            mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: mod[:on] } }
          end

          def calculate_c_pulses(mod, pulse)
            mod[:inputs][pulse[:source]] = pulse[:high]

            # puts "#{@round}) #{mod}" if pulse[:dest] == :bb && mod[:inputs].values.select { |t| t }.length > 1
            # if pulse[:dest] == :bb && mod[:inputs].values.any?

            # puts "received: #{pulse}| pre: #{mod}"
            high = !mod[:inputs].values.all?
            # puts "received: #{pulse}| post: #{mod}"

            mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: } }
          end

          def modules_key
            # JSON.dump(@modules.reject { |k,v| k == :bb || v[:dests].include?(:bb) } )
            # JSON.dump(@modules.select { |_, v| v[:type] == :f } )
            @modules.select { |_, v| v[:type] == :f }.sort.map { |_k, v| v[:on] ? "O" : "_" }.join
            # @modules.sort.map { |k,v| v[:type] == :f ? (v[:on] ? "O" : "_") : "" }.join
            # @modules.sort.map(&:last).map do |mod|
            #   mod[:type]
            # end.join
          end

          def star_one
            reset_modules
            low_total = 0
            high_total = 0
            1000.times.each do |_r|
              counts = count_pulses
              low_total += counts[0]
              high_total += counts[1]
            end
            logger.info { "Low: #{low_total} | Hight: #{high_total}" }
            logger.warn "Star one answer: #{low_total * high_total}"
          end

          def find_important_modules
            important = [:rx]
            found = {}
            until important.empty?
              important = important.map do |i|
                new_important = []
                # puts i
                @inputs_map[i]&.each_key do |key|
                  new_important << key unless found[key]
                  found[key] = true
                end
                new_important
              end.flatten
            end
            puts found.length
            puts @modules.length
          end

          def get_loops # rubocop:disable Metrics/AbcSize
            @loops = @modules[:broadcaster][:dests].to_h { |d| [d, { items: [d], cache: {}, ends: [] }] }
            @loops.each_value do |loop|
              loop[:items].each do |mod|
                # puts mod
                @modules[mod][:dests].each do |dest|
                  if dest == :bb
                    loop[:final] = mod
                  elsif !loop[:items].include? dest
                    loop[:items] << dest
                  end
                end
              end
            end
            puts @loops

            reset_modules
            round = 0
            until @loops.values.all? { |v| v[:size] }
              round += 1
              do_pulses
              @loops.each do |loop_name, loop|
                next if loop[:size]

                cache_key = (@modules.filter { |k, _| loop[:items].include? k }.sort.map do |_k, v|
                  case v[:type]
                  when :f then v[:on] ? "#" : "_"
                  when :c then v[:inputs].sort.map { |_, i| i ? "^" : "v" }.join
                  else ""
                  end
                end).join
                # puts cache_key if loop_name == :fr
                # puts "FINAL IS TRUE (#{round}/#{loop_name})" if @modules[loop[:final]][:inputs].values.none?
                if loop[:cache][cache_key]
                  logger.warn "Found loop for #{loop_name}, size: #{round}"
                  loop[:size] = round - 1 # Damn this -1 with no example answers for part 2!!!
                else
                  loop[:cache][cache_key] = true
                end
              end
            end
          end

          def show_map(name = :broadcaster, prefix = "")
            @shown ||= {}
            mod = @modules[name]
            # puts @shown
            return unless mod

            puts "#{prefix}#{name}[#{mod[:type]}] =>"
            mod[:dests].each do |dest|
              if @shown[dest]
                puts "| #{prefix}*** #{dest}"
              else
                @shown[dest] = true
                show_map dest, "#{prefix}| "
              end
            end
            # @modules.each do |name, mod|
            #   puts "#{name} => #{mod[:dests].join(" ")}"
            # end
          end

          def star_two
            get_loops
            round = 0
            logg_round = 1
            logger.warn "Star two answer: #{@loops.map { |_, v| v[:size] }.inject(1, :lcm)}"
            # exit

            increment = @loops.values.first[:size] * @loops.values.last[:size]
            loop do
              round += increment
              logger.info { "#{round}) #{@loops.values.map { |v| (round % v[:size]).zero? ? "*" : "_" }.join}" }
              found = true
              @loops.each_value do |loop|
                found = false if round % loop[:size] != 0
              end
              if round > logg_round
                puts round
                logg_round *= 10
              end
              # puts found
              break if found
            end
            logger.warn "Star two answer: #{round}"
          end

          # def guess_flip(round, actual_flip)
          #   @loop ||= {}
          #   actual_flip.chars.map.with_index do |c, i|
          #     if @loop[i]
          #       @round % (@loop[i]*2) >= @loop[i] ? "O" : "_"
          #       # @pattern[i].call(round) ? "O" : "_"
          #     else
          #       @loop[i] = round if c == "O"
          #       c
          #     end
          #   end.join
          # end
        end
      end
    end
  end
end

# s2 too low:         500000000
# s2 too low:        2055000000
# s2 too high:  211934525900544
# no         :   13245907868783
# no         :   13245907868784
# no         :   13245907868785
#                   10000001432
