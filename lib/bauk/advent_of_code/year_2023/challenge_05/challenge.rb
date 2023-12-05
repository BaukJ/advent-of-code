# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge05
        # Challenge for 2023/05
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @maps = {}
            @found = {}
            @mappings = []
            @smallest_range = @lines[3].split.last.to_i # Used to provide speed improvements and skip numbers
            @lines.each do |line|
              parse_line line
            end
            logger.warn "Finished parsing. Smallest range: #{@smallest_range}"
          end

          def parse_line(line)
            case line
            when /^seeds: ([0-9 ]*)$/ then @seeds = $1.split.map(&:to_i)
            when /^([a-z]*)-to-([a-z]*) map:$/
              die "ALready defined" if @maps[$1]
              logger.info "Parsing: #{line}"
              @maps[$1] = { destinations: {}, destination_type: $2 }
              @map = @maps[$1]
              @found[$1] = {}
              @found[$2] = {}
              @mappings << []
            when /^ *$/ then nil
            when /^([0-9 ]+) ([0-9 ]+) ([0-9 ]+)$/
              add_map_destinations line.split.map(&:to_i)
              @smallest_range = $3.to_i if $3.to_i < @smallest_range
              @mappings[-1] << {source: $2.to_i, dest: $1.to_i, count: $3.to_i, source_end: $2.to_i + $3.to_i - 1, dest_end: $1.to_i + $3.to_i - 1, modifier: $1.to_i - $2.to_i}
            else
              die "Invalid line: #{line}"
            end
          end

          def add_map_destinations(numbers)
            start_dest, start_source, count = numbers
            # Two ways of storing dests, one for quick retrueval, one for quick parsing
            # (0...count).each do |i|
            #   @map[:destinations][start_source + i] = start_dest + i
            # end
            @map[:dests] ||= []
            @map[:dests] << { source: start_source, dest: start_dest, count:, source_end: start_source + count - 1 }
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two_two
          end

          def star_one
            @locations = []
            @seeds.each do |seed|
              @locations << find_location_two(seed)
            end
            logger.info "Locations: #{@locations.inspect}"
            logger.warn "Star one answer: #{@locations.min}"
          end

          def find_location(seed, type = "seed")
            # if @found[type][seed]
            #   logger.info { "ALready found #{seed}/#{type}" }
            #   return false
            # end
            # @found[type][seed] = true
            # logger.debug { "TYPE: #{type}, NUM: #{seed}"}
            return seed unless @maps[type]

            new_type = @maps[type][:destination_type]
            dest = find_destination(seed, type)
            find_location(dest, new_type)
          end

          def find_destination(source, type)
            @maps[type][:dests].each do |dest|
              next unless source.between? dest[:source], dest[:source] + dest[:count] - 1

              return source + dest[:dest] - dest[:source]
            end
            source
          end

          def find_location_two(seed)
            @mappings.each do |mapping|
              mapping.each do |dest|
                if seed.between? dest[:source], dest[:source_end]
                  seed += dest[:modifier]
                  break
                end
              end
            end
            seed
          end

          def find_smallest_location
            location = Opts.start_location
            info_location = location + 100_000
            loop do
              location += 1
              seed = find_seed location
              if seed_exists? seed
                logger.warn "Found smallest location (#{location}) which maps to seed #{seed}"
                break
              end
              logger.debug { "#{location.underscore} => #{seed.underscore}" }
              if location >= info_location
                logger.info { "#{location.underscore} => #{seed.underscore}" }
                info_location += 100_000
              end
            end
            location
          end

          def find_seed(location)
            @mappings.reverse.each do |mapping|
              mapping.each do |dest|
                if location.between? dest[:dest], dest[:dest_end]
                  location -= dest[:modifier]
                  break
                end
              end
            end
            location
          end

          # A improved speed version using multipl seeds, didn't need to get implemented as I got the answer the slow way
          def find_seeds(locations)
            @mappings.reverse.each do |mapping|
              mapping.each do |dest|
                if location[0].between? dest[:dest], dest[:dest_end]
                  if location[-1].between? dest[:dest, dest[:dest_end]]
                    locations.map! { |l| l - dest[:modifier] }
                    # TODO
                  end
                  break
                end
              end
            end
            location
          end

          def seed_exists?(seed)
            @seeds.each_slice(2) do |start, count|
              return true if seed >= start && seed < start + count
            end
            false
          end

          def star_two
            @min_location = 999999999999999
            @all_seeds = []
            seeds_done = 0
            @seeds.each_slice(2) do |start, count|
              logger.info "Doing seeds from #{start} (count #{count})"
              (start...(start + count)).each do |seed|
                seeds_done += 1
                # break if seeds_done >= 1_000_000
                location = find_location_two4(seed)
                @min_location = location if location && location < @min_location
                # @all_seeds << seed
              end
            end
            logger.warn "Star two answer: #{@min_location}"
          end

          def star_two_two
            logger.warn "Star two answer: #{find_smallest_location}"
          end
        end
      end
    end
  end
end

# Monkey-patch integer to be able to pretty print with underscores
class Integer
  def underscore
    to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1_")
  end
end
