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
              @moves[$1] = {"L" => $2, "R" => $3}
            end
            @index = 0
            @nodes = @moves.keys.select do |node|
              node[-1] == "A"
            end
            @node_details = @nodes.map { |n| { start: n, positions: [n] } }
            logger.warn "Steps size: #{@steps.length}, Nodes size: #{@nodes.length}"
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def do_step
            @position = step @position
            @index += 1
            if @index >= @steps.length
              @index = 0
              logger.debug { "Progress: #{@nodes.select { |n| n[-1] == "Z" }.length}" }
            end
          end

          def parse_nodes
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
                  if @node_details[index][:positions].include?(new_node) && @node_details[index][:positions].map.with_index { |n, i| [n, i] }.select { |n, i| n == new_node }.any? { |n,i| i == @index }
                    complete += 1
                    logger.info { "Completed: #{complete}/#{@nodes.length}"}
                    @node_details[index][:loop_size] = @node_details[index][:positions].length
                    @node_details[index][:ends] = @node_details[index][:positions].map { |p| p[-1] == "Z" }
                  else
                    @node_details[index][:positions] << new_node
                  end
                  new_node
                end
              end
              update_index
              break unless updated
            end
            puts @node_details.inspect
            puts
            puts @node_details[0].inspect
            logger.warn "Parsing nodes...DONE"
          end

          def do_nodes
            @nodes.map! { |n| step n }
            update_index
          end

          def update_index
            @index += 1
            @index = 0 if @index >= @steps.length
          end

          def step(position)
            # logger.debug { "#{position} => #{@steps[@index]}(#{@index}) => #{@moves[position][@steps[@index]]}"}
            @moves[position][@steps[@index]]
          end

          def node_end?(node)
            index = @index
            if index >= node[:loop_size]
              puts step()
            end
            node[:ends][index]
            # if @index 
            #   if node[:ends][@index]
          end

          def node_position(node)
            index = @index + 1
            if index >= node[:loop_size]
              exit
            end
            puts node[:start]
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

          def star_two
            @count = 0
            @index = 0
            if File.exist? "cache.json"
              @node_details = JSON.load_file "cache.json", {:symbolize_names => true}
            else
              parse_nodes
              File.write "cache.json", JSON.dump(@node_details)
            end
            # exit
            @count = 0
            @index = 0
            until @nodes.all? { |n| n[-1] == "Z" }
              p = node_position(@node_details[0])
              do_nodes
              puts "#{@nodes[0]} == #{p}"
              die "" if @nodes[0] != p
              # sleep 1
              @count += 1
            end
            logger.warn "Star two answer: #{@count}"
          end
        end
      end
    end
  end
end
