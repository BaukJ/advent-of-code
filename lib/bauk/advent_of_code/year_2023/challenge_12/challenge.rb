# frozen_string_literal: true

require_relative "../../base_challenge"

# Star two: too low : 1000000000000
# Star two: too     :
# Star two: too high: 7000000000000
# Star two: too high: 7924317551937
# Star two: too ?   : 7957192579138

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge12
        # Challenge for 2023/12
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @max_section_length = Opts.max_section_length
            @arrangements = []
            @rows = []
            @lines = @lines.map do |line|
              parts = line.split
              @arrangements << parts[1].split(",").map(&:to_i)
              @rows << parts[0].chars
              parts[0]
            end
            @map = Map.from_lines @lines
          end

          def run
            logger.info("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def find_combinations(row, arrangement)
            parts = row.each_slice(@max_section_length).map(&:join)
            # parts = row.join.split(/\.+/) #.map { |p| p.split }
            logger.debug "Generating parts map for #{row.join}"
            generate_parts_map parts, arrangement.max
            logger.debug "Generating parts map for #{row.join} DONE"
            logger.debug { "PARTS MAP: #{@parts_map.inspect}" }
            logger.debug { "PARTS COMBINATIONS: #{@part_combinations.inspect}" }
            combinations = find_combinations_from_parts row, arrangement
            logger.info { "Found #{combinations} combinations for #{row}" }
            combinations
          end

          def find_combinations_from_parts(parts, arrangement)
            curr = { "" => 1 }
            # puts parts.inspect
            # puts parts.length
            # l = 0
            # parts.each_slice(@max_section_length) { |s| l += s.length }
            # puts l
            parts.each_slice(@max_section_length) do |slice|
              # puts slice.inspect
              logger.debug { "Arrangement/current patterns) #{arrangement.join("_")} // #{curr.inspect}" }
              next_curr = {}
              combinations = generate_part_combinations(slice.dup)
              # cominations = @part_combinations[slice]
              die "NO COMBINATIONS!" if combinations.empty?
              # puts combinations.inspect
              curr.each do |p, pattern_count|
                pattern = p.clone.split("_")
                logger.debug { "Adding #{p} + #{slice}" }

                if pattern.length > arrangement.length
                  puts "TOO LONG: #{pattern.inspect} should match #{arrangement.inspect}"
                  nil # We're too long
                elsif pattern[-1]&.sub!(/\$$/, "")
                  if pattern[-1].to_i < arrangement[pattern.length - 1]
                    tail = pattern.pop.to_i
                    combinations.each do |c, combination_count|
                      logger.debug { "Checking combination: #{c}" }
                      combination = c.dup
                      next if combination.empty? || !combination.sub!(/^\^/, "")

                      comb_items = combination.split("_")
                      # puts "COMB ITEMS: #{comb_items}"
                      # puts :checking_comb
                      next unless valid_combination?(pattern, arrangement, comb_items, next_curr, tail)

                      # puts :valid_comb
                      # puts "HERE"
                      head = comb_items.shift
                      join = (head.to_i + tail).to_s + (head.end_with?("$") ? "$" : "")
                      next_p = [pattern.join("_"), join, comb_items.join("_")].reject(&:empty?).map { |o| o.sub(/^\^/, "") }.join("_").gsub("$_", "_")
                      next_curr[next_p] ||= 0
                      next_curr[next_p] += pattern_count * combination_count
                      logger.debug { "Added: #{next_p}" }
                    end
                  else
                    # Reject any that start with a ^
                    combinations.each do |c, combination_count|
                      logger.debug { "Checking combination: #{c}" }
                      combination = c.dup
                      next if combination.start_with?("^")

                      comb_items = combination.split("_")
                      next unless valid_combination?(pattern, arrangement, comb_items, next_curr)

                      next_p = [pattern.join("_"), c].reject(&:empty?).map { |o| o.sub(/^\^/, "") }.join("_").gsub("$_", "_")
                      next_curr[next_p] ||= 0
                      next_curr[next_p] += pattern_count * combination_count
                      logger.debug { "Added: #{next_p}" }
                    end
                  end
                else
                  # puts "AAAAAAAAAAAAAAA: #{slice} / #{combinations.inspect}"
                  combinations.each do |c, combination_count|
                    logger.debug { "Checking combination: #{c}" }
                    combination = c.clone.sub(/^\^/, "")
                    comb_items = combination.split("_")
                    next unless valid_combination?(pattern, arrangement, comb_items, next_curr)

                    next_p = [p, c].reject(&:empty?).map { |o| o.sub(/^\^/, "") }.join("_").gsub("$_", "_")
                    next_curr[next_p] ||= 0
                    next_curr[next_p] += pattern_count * combination_count
                    logger.debug { "Added: #{next_p}" }
                  end
                end
              end
              curr = next_curr
              if curr.empty?
                logger.error "Could not find any combinations!"
                return 0
              end
              logger.debug { "Current combinations sum: #{curr.values.sum}" }
            end
            total = 0
            curr.each do |k, v|
              if k.split("_").length == arrangement.length
                if k.sub("$", "") == arrangement.join("_")
                  total += v
                else
                  logger.info "NO MATCH! #{k.sub("$", "")} != #{arrangement.join("_")}"
                end
              else
                logger.debug { "Not long enough combinations: #{k} / #{arrangement}" }
              end
            end
            total
          end

          def valid_combination?(current_pattern, arrangement, comb_items, _next_curr, tail = 0)
            comb_items.each_with_index do |item, index|
              return false unless valid_addition?(current_pattern, arrangement, item, index, index.zero? ? tail : 0)
            end
            true
          end

          def valid_addition?(current_pattern, arrangement, item, index, tail)
            arrangement_index = current_pattern.length + index
            # puts "item:#{item}, tail:#{tail}, a_index: #{arrangement_index}, arrangement:#{arrangement[arrangement_index]}, curr_pattern: #{current_pattern}, i: #{index}"
            if arrangement_index >= arrangement.length
              # puts :too_long
              # true
              false
            elsif (item.to_i + tail) == arrangement[arrangement_index]
              true
            elsif (item.to_i + tail) < arrangement[arrangement_index] && item.end_with?("$")
              true
            else
              false
            end
          end

          def generate_parts_map(parts, longest_run)
            @parts_map ||= {}
            @part_combinations ||= {}
            @longest_run = longest_run
            parts.uniq.each do |part|
              next if @parts_map[part]

              combinations = generate_part_combinations part.chars
              combinations_tally = combinations.keys.tally

              @parts_map[part] = {}
              combinations.keys.uniq.each do |key|
                @parts_map[part][key] = { count: combinations_tally[key], combinations: key.split("_").map(&:to_i) }
              end
              # puts "C keys: #{combinations_keys.inspect}"
              # puts combinations.inspect
              # puts @parts_map.inspect
            end
          end

          def add_halves(first_half, second_half, combination, joint = false) # rubocop:disable Metrics/AbcSize
            logger.debug { "PRE JOINED: #{combination.inspect}" }
            logger.debug { "First half: #{first_half.inspect}" }
            logger.debug { "Second half: #{second_half.inspect}" }
            if first_half.empty?
              second_half.each do |k, c|
                combination[k] ||= 0
                combination[k] += c
              end
            elsif second_half.empty?
              first_half.each do |k, c|
                combination[k] ||= 0
                combination[k] += c
              end
            else
              count = 0
              first_half.each do |fk, first_count|
                second_half.each do |sk, second_count|
                  count += 1

                  first_key = fk
                  second_key = sk
                  join_key = joint

                  if first_key.end_with?("$")
                    first_key = first_key[0...-1]
                  else
                    join_key = false
                  end
                  if second_key.start_with?("^")
                    second_key = second_key[1..]
                  else
                    join_key = false
                  end
                  # puts "#{fk}/#{sk} (join: #{join_key})"
                  if join_key
                    firsts = first_key.split("_").map { |c| c.gsub(/[^0-9]/, "") }
                    seconds = second_key.split("_").map { |c| c.gsub(/[^0-9]/, "") }
                    key = [*firsts[0...-1], (firsts[-1].to_i + seconds[0].to_i).to_s, *seconds[1..]].reject(&:empty?).join("_")
                    key += "$" if second_key.end_with? "$"
                    key.prepend("^") if first_key.start_with? "^"
                  else
                    key = [first_key, second_key].reject(&:empty?).join("_")
                  end
                  combination[key] ||= 0
                  combination[key] += first_count * second_count
                end
              end
            end
            # puts "JOINED: #{combination.inspect}"
          end

          def generate_part_combinations(part_chars)
            return @part_combinations[part_chars.join] if @part_combinations[part_chars.join]

            combination = {}
            if part_chars.length > @max_section_length
              part_chars.each_slice(@max_section_length) do |slice|
                generate_part_combinations(slice)
                # new_combination = {}
                # add_halves(combination, generate_part_combinations(slice), new_combination, true)
                # combination = new_combination
              end
            # elsif part_chars.join.start_with?("#" * @longest_run)
            #   return {} # invalid for this generation
            elsif part_chars.include? "?"
              part_chars.each_with_index do |char, i|
                next unless char == "?"

                first_parts = part_chars[0...i]
                second_parts = part_chars[i + 1..]
                first_half = generate_part_combinations(first_parts + ["."]) # unless first_parts.empty?
                first_half_joined = generate_part_combinations(first_parts + ["#"]) # unless first_parts.empty?
                second_half = generate_part_combinations(second_parts) # unless second_parts.empty?
                logger.debug { "DOING: #{part_chars.join}" }
                add_halves(first_half_joined, second_half, combination, true)
                add_halves(first_half, second_half, combination, true)

                # combination += generate_part_combinations(part_chars[0...i]) + generate_part_combinations(part_chars[i+1..])
                # return combination
                break
              end
            elsif part_chars.empty?
              combination = {}
            else
              c = part_chars.join.split(/\.+/).map(&:length).reject(&:zero?).join("_")
              c += "$" if part_chars[-1] == "#"
              c.prepend("^") if part_chars[0] == "#"
              combination = { c => 1 }
            end
            logger.debug { "#{part_chars.join} => #{combination}" }
            @part_combinations[part_chars.join] = combination
            logger.debug { "Done #{part_chars.join}. Cache size (part_combinations): #{@part_combinations.length}, combination size: #{combination.length}" }
            combination
          end

          def find_combination(row, arrangement, current_arrangement = [], chain = 0) # rubocop:disable Metrics/AbcSize
            # logger.debug { "ROW: #{row}" }
            combinations = 0
            row.each_with_index do |char, index| # rubocop:disable Metrics/BlockLength
              # logger.debug { "Current start: #{current_arrangement.inspect} + #{chain}"}
              if char == "?"
                if arrangement.length == current_arrangement.length
                  char = "."
                elsif chain.positive?
                  char = if chain < arrangement[current_arrangement.length]
                           # Must be broken if chain needs to be longer
                           "#"
                         else
                           "."
                         end
                elsif !can_start_chain?(row[index..], arrangement[current_arrangement.length])
                  char = "."
                else
                  combinations += find_combination(["."] + row[(index + 1)..], arrangement, current_arrangement.clone, chain)
                  combinations += find_combination(["#"] + row[(index + 1)..], arrangement, current_arrangement.clone, chain)
                  return combinations
                end
              end
              case char
              when "#" then chain += 1
              when "."
                if chain.positive?
                  current_arrangement << chain
                  chain = 0
                end
                # else die "Invalid char: #{char}"
              end
              return 0 unless chain.positive? || valid?(current_arrangement, arrangement, chain, row[index + 1..])

              # logger.debug { "Current: #{current_arrangement.inspect} + #{chain}"}
            end
            current_arrangement << chain if chain.positive?
            # logger.debug { "Final chain: #{current_arrangement.inspect}"}
            combinations += 1 if valid?(current_arrangement, arrangement) && arrangement.length == current_arrangement.length
            combinations
          end

          def can_start_chain?(rows_left, chain_length)
            (0...chain_length).each do |i|
              return false if rows_left[i] == "."
            end
            true
          end

          def valid?(current_arrangement, arrangement, _chain = 0, _rows_left = [])
            # Just check the last length, the other should already be checked
            return false if !current_arrangement.empty? && current_arrangement[-1] != arrangement[current_arrangement.length - 1]
            # current_arrangement.each_with_index do |a, i|
            #   return false if a != arrangement[i]
            # end
            return false if current_arrangement.length > arrangement.length

            # if chain.positive?
            #   return false if current_arrangement.length >= arrangement.length || chain > arrangement[current_arrangement.length]
            # end
            # See if we have enough rows left to comply
            # broken_left = 0
            # min_length = (current_arrangement.length...arrangement.length).each.inject(0) do |length, index|
            #   length += 1 if length != 0
            #   broken_left += arrangement[index]
            #   length += arrangement[index]
            #   length
            # end - chain
            # return false if min_length > rows_left.length
            # return false if rows_left.select {|r| r == "?" || r == "#" }.length < arrangement[current_arrangement.length..].sum - chain

            true
          end

          def star_one
            puts @map
            @total = 0
            @rows.each_with_index do |row, index|
              arrangement = @arrangements[index]
              @total += find_combinations row, arrangement
            end
            logger.warn "Star one answer: #{@total}"
          end

          def star_two
            @times = Opts.expand
            # @part_combinations ||= {}
            # generate_part_combinations(["#", "#", "#", "?"])
            # exit
            # puts @rows[2].join.inspect
            @rows.map! do |row|
              (1..@times).map { row.join }.join("?").chars
            end
            # puts @rows[2].join.inspect
            @arrangements.map! do |arrangement|
              (1..@times).inject([]) { |obj, _i| obj + arrangement }
            end
            # puts @arrangements[0].inspect
            # exit
            @total = 0
            @rows = @rows[0...Opts.rows] if Opts.rows.positive?
            @rows.each_with_index do |row, index|
              arrangement = @arrangements[index]
              @total += find_combinations row, arrangement
              # break
            end
            logger.warn "Star two answer: #{@total}"
          end
        end
      end
    end
  end
end
