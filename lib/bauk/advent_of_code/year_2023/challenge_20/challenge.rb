# frozen_string_literal: true
# s1 too high 908202812

require_relative "../../base_challenge"
require "benchmark"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge20
        # Challenge for 2023/20
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @pattern_length = 10
            @modules = {
              button: {dests: [:broadcaster], type: :b}
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
                @modules[name] = {dests:, type: :b}
              elsif type == "%"
                @modules[name] = {dests:, on: false, type: :f}
              elsif type == "&"
                @modules[name] = {dests:, type: :c}
              end
            end
            @modules.each do |name, mod|
              mod[:inputs] = @inputs_map[name] if mod[:type] == :c
            end
            @reset_modules = JSON.dump(@modules)
          end

          def reset_modules
            @modules = JSON.parse(@reset_modules, symbolize_names: true)
            @modules.each do |_, mod|
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
            pulses = [{high: false, dest: :broadcaster, source: :button}]
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
                  new_pulses += mod[:dests].map { |d| {source: pulse[:dest], dest: d, high: pulse[:high]}}
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
            pulses = [{high: false, dest: :broadcaster, source: :button}]
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
                  new_pulses += mod[:dests].map { |d| {source: pulse[:dest], dest: d, high: pulse[:high]}}
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
            mod[:dests].map { |d| {source: pulse[:dest], dest: d, high: mod[:on] }}
          end

          def calculate_c_pulses(mod, pulse)
            mod[:inputs][pulse[:source]] = pulse[:high]

            # puts "#{@round}) #{mod}" if pulse[:dest] == :bb && mod[:inputs].values.select { |t| t }.length > 1
            #if pulse[:dest] == :bb && mod[:inputs].values.any?

            # puts "received: #{pulse}| pre: #{mod}"
            high = !mod[:inputs].values.all?
            # puts "received: #{pulse}| post: #{mod}"

            mod[:dests].map { |d| { source: pulse[:dest], dest: d, high: } }
          end

          def modules_key
            # JSON.dump(@modules.reject { |k,v| k == :bb || v[:dests].include?(:bb) } )
            # JSON.dump(@modules.select { |_, v| v[:type] == :f } )
            @modules.select { |_, v| v[:type] == :f }.sort.map { |k,v| v[:on] ? "O" : "_" }.join
            # @modules.sort.map { |k,v| v[:type] == :f ? (v[:on] ? "O" : "_") : "" }.join
            # @modules.sort.map(&:last).map do |mod|
            #   mod[:type]
            # end.join
          end

          def star_one
            reset_modules
            low_total = 0
            high_total = 0
            1000.times.each do |r|
              counts = count_pulses
              low_total += counts[0]
              high_total += counts[1]
            end
            logger.info { "Low: #{low_total} | Hight: #{high_total}" }
            logger.warn "Star one answer: #{low_total*high_total}"
          end

          def find_important_modules
            important = [:rx]
            found = {}
            until important.empty?
              important = important.map do |i|
                new_important = []
                # puts i
                @inputs_map[i]&.keys&.each do |key|
                  new_important << key unless found[key]
                  found[key] = true
                end
                new_important
              end.flatten
            end
            puts found.length
            puts @modules.length
          end

          def get_loops
            @loops = @modules[:broadcaster][:dests].map { |d| [d, {items: [d], cache: {}, ends: []}] }.to_h
            @loops.each do |k,loop|
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
                cache_key = (@modules.filter { |k,_| loop[:items].include? k }.sort.map do |k,v|
                  case v[:type]
                  when :f then v[:on] ? "#" : "_"
                  when :c then v[:inputs].sort.map { |_,i| i ? "^" : "v" }.join
                else ""
                end
              end).join
              # puts cache_key if loop_name == :fr
                # puts "FINAL IS TRUE (#{round}/#{loop_name})" if @modules[loop[:final]][:inputs].values.none?
                if loop[:cache][cache_key]
                  logger.warn "Found loop for #{loop_name}, size: #{round}"
                  loop[:size] = round
                else
                  loop[:cache][cache_key] = true
                end
              end
              exit if round >10000
            end
            exit
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
                show_map dest, prefix + "| "
              end
            end
            # @modules.each do |name, mod|
            #   puts "#{name} => #{mod[:dests].join(" ")}"
            # end
          end 

          def star_two
            get_loops
            # puts modules_key
            # return
            reset_modules
            # show_map
            # return
            # find_important_modules
            # return
            die unless @modules[:bb] # This goes to rx but isn't in the test data
            @round = Opts.start_round

            if @round > 0
              @modules = Utils.cache("y23c20_#{@round}") do
                @round.times do
                  count_pulses
                end
                @modules
              end
              @modules.each do |_, mod|
                mod[:type] = mod[:type].to_sym
                mod[:dests].map!(&:to_sym)
              end
            end
            
            @flips = {}
            @round_cache = {}
            puts "      " + (0..50).map { |i| i.to_s[-1] }.join
            loop do
              @round += 1
              do_pulses
              puts @modules[:bb] if @modules[:bb][:inputs].values.any?
              break if @rx.positive?
              # puts @round if @round.to_s =~ /^10*$/
              # Utils.cache_save("y23c20_#{@round}", @modules) if @round % 100_000 == 0
              # puts @modules.sort.map { |_,v| v }[3]
              break if @round >= 5000
              # puts (@modules.sort.map do |k,v|
              #   case v[:type]
              #   when :f then v[:on] ? "#" : "_"
              #   when :c then v[:inputs].sort.map { |_,i| i ? "^" : "v" }.join
              #   else ""
              #   end
              # end).join

              
              # mkey = modules_key
              # if @round_cache[mkey]
              #   puts "FOUND LOOP!!!!! #{@round}"
              #   return
              # else
              #   @round_cache[mkey] = true
              # end
              # # expected_c = @modules.select { |k, v| v[:type] == :c }.sort.map { |k, v| v[:inputs].values.all? ? "O" : "_" }.join
              # expected_c = @modules.select { |k, v| v[:type] == :c }.sort.map { |k, v| v[:inputs].sort.map { |_,high| high ? "O" : "_" } }.join("-")
              # puts "#{@round}) #{expected_c}" unless expected_c == "_O_OO_O__"

              # expected_flip = @modules.select { |k, v| v[:type] == :f }.sort.map { |k, v| v[:on] ? "O" : "_" }.join
              # guessed_flip = guess_flip(@round, expected_flip)
              # # puts "#{@round.to_s.rjust(4)}) #{expected_flip}  (#{@loop.length}/#{expected_flip.length})"
              # # puts "#{@round.to_s.rjust(4)}) #{guessed_flip}"
              # if expected_flip != guessed_flip
              #   puts
              #   puts (0..50).map { |i| i.to_s[-1] }.join
              #   puts expected_flip
              #   puts guessed_flip
              #   die "WRONG GUESS"
              # end
              # # retrurn if expected_flip =~ /^O*$/
            end
            # puts @loop
            logger.warn "Star two answer: #{@round} (rx: #{@rx})"
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

# s2 too low:  500000000
# s2 too low: 2055000000
