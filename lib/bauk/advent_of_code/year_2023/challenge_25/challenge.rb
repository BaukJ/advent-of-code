# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge25
        # Challenge for 2023/25
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @nodes = {}
            @reverse_nodes = {}
            @all_nodes = {}
            @lines.each do |line|
              start, finishes = line.split(": ")
              @nodes[start] ||= {}
              @all_nodes[start] = true
              finishes.split(" ").each do |finish|
                @nodes[start][finish] = true
                @reverse_nodes[finish] ||= {}
                @reverse_nodes[finish][start] = true
                @all_nodes[finish] = true
              end
            end
            puts @nodes.inspect
            puts @reverse_nodes.inspect
          end

          def into_groups
            nodes = @all_nodes.deep_clone
            groups = []
            new_nodes = []
            group = {}
            until nodes.empty?
              if new_nodes.empty?
                # New group found
                new_nodes = [nodes.shift]
                groups << group unless group.empty?
                group = {}
              else
                new_nodes.each do |node|
                  group[node] = true
                  @nodes[node].each do |joined|
                    # new_
                  end
                end
              end
            end
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def star_one
            logger.warn "Star one answer: "
          end

          def star_two
            logger.warn "Star two answer: "
          end
        end
      end
    end
  end
end
