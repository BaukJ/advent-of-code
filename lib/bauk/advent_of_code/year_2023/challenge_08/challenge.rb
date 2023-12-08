# frozen_string_literal: true

require_relative "../../base_challenge"
require "json"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge08
        # Challenge for 2023/08
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @steps = @lines.shift.chars
            @lines.shift
            @position = "AAA"
            @moves = {}
            @lines.each do |line|
              die "T: #{line}" unless line =~ /^([A-Z0-9]{3}) *= *\(([A-Z0-9]{3}), ([A-Z0-9]{3})\)$/
              @moves[$1] = { "L" => $2, "R" => $3 }
            end
            @index = 0
            @nodes = @moves.keys.select do |node|
              node[-1] == "A"
            end
            # @node_details = @nodes.map { |n| { start: n, positions: [n] } }
            @node_details = @nodes.map { |n| { start: n, positions: [] } }
            logger.warn "Steps size: #{@steps.length}, Nodes size: #{@nodes.length}"
            @total_index = 0
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def do_step
            @position = step @position
            @index += 1
            return unless @index >= @steps.length

            @index = 0
          end

          def parse_nodes # rubocop:disable Metrics/AbcSize
            logger.warn "Parsing nodes..."
            complete = 0
            loop do
              updated = false
              @nodes.map!.with_index do |node, index|
                if @node_details[index][:loop_size]
                  node
                else
                  updated = true
                  new_node = step node
                  if @node_details[index][:positions].include?(new_node) && @node_details[index][:positions].map.with_index do |n, i|
                                                                              [n, i]
                                                                            end.select { |n, _i| n == new_node }.any? { |_n, i| i == @index }
                    complete += 1
                    logger.info { "Completed: #{complete}/#{@nodes.length}" }
                    @node_details[index][:ends] = @node_details[index][:positions].map { |p| p[-1] == "Z" }
                    loop_start = @node_details[index][:positions].map.with_index { |n, i| [n, i] }.select { |n, i| n == new_node && i == @index }[0]
                    @node_details[index][:loop_start] = loop_start[0]
                    @node_details[index][:loop_start_index] = loop_start[1]
                    # @node_details[index][:start_index] = @index
                    @node_details[index][:loop_size] = @node_details[index][:positions].length - @node_details[index][:loop_start_index]
                    @node_details[index][:positions_size] = @node_details[index][:positions].length
                  else
                    @node_details[index][:positions] << new_node
                  end
                  new_node
                end
              end
              update_index
              break unless updated
            end
            logger.warn "Parsing nodes...DONE"
          end

          def do_nodes
            @nodes.map! { |n| step n }
            update_index
          end

          def update_index(add = 1)
            @index += add
            @total_index += add
            @index %= @steps.length
          end

          def step(position)
            # logger.debug { "#{position} => #{@steps[@index]}(#{@index}) => #{@moves[position][@steps[@index]]}"}
            @moves[position][@steps[@index]]
          end

          def node_end?(node)
            index = @total_index
            if index >= node[:positions_size]
              index -= node[:loop_start_index]
              index %= node[:loop_size]
              index += node[:loop_start_index]
            end
            node[:ends][index]
          end

          def node_position(node)
            index = @total_index
            if index >= node[:positions_size]
              index -= node[:loop_start_index]
              index %= node[:loop_size]
              index += node[:loop_start_index]
            end
            @logger.warn "Went from #{@total_index} to #{index}"
            node[:positions][index]
          end

          def star_one
            @count = 0
            until @position == "ZZZ"
              do_step
              @count += 1
            end
            logger.warn "Star one answer: #{@count}"
          end

          def star_two # rubocop:disable Metrics/AbcSize
            cache_file = "cache-#{Opts.file}.json"
            if File.exist? cache_file
              @node_details = JSON.load_file cache_file, symbolize_names: true
            else
              @index = 0
              parse_nodes
              File.write cache_file, JSON.dump(@node_details)
            end
            # compact_node_details
            @index = Opts.start % @steps.length
            @total_index = Opts.start
            count_debug = Opts.start
            found_node_one = false
            until @node_details.all? { |node| node_end? node }
              if @total_index > count_debug
                logger.debug { "#{@total_index}..." }
                count_debug += 100_000_000_000
              end
              if node_end?(@node_details[0])
                to_add = @node_details[0][:loop_size]
                found_node_one = true
              else
                die "Technical error" if found_node_one
                to_add = 1
              end
              update_index to_add
            end
            logger.warn "Star two answer: #{@total_index + 1}" # As index 0 is count 1
          end
        end
      end
    end
  end
end
