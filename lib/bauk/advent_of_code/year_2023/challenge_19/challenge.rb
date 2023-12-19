# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge19
        # Challenge for 2023/19
        class Challenge < BaseChallenge
          def initialize # rubocop:disable Metrics/AbcSize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @workflows = {}
            @parts = []
            parts = false
            @lines.each do |line|
              if line.empty?
                parts = true
              elsif parts
                die unless line =~ /^{(.*)}$/
                @parts << $1.split(",").to_h do |a|
                  k, v = a.split("=")
                  [k.to_sym, v.to_i]
                end
              else
                die "Invalid" unless line =~ /^([a-z]*){(.*)}$/
                workflow = $1
                @workflows[workflow] = []
                $2.split(",").each do |rule|
                  if rule =~ /^([amsx])([><])([0-9]+):([ARa-z]+)$/
                    @workflows[workflow] << {
                      attr: $1.to_sym,
                      check: $2,
                      value: $3.to_i,
                      destination: $4
                    }
                  elsif rule =~ /^([ARa-z]*)$/
                    @workflows[workflow] << rule
                  else
                    die rule
                  end
                end
              end
            end
            puts @parts.inspect
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def parse_parts
            accepted = []
            @parts.each do |part|
              accepted << part if put_part_through_workflow part, "in"
            end
            accepted
          end

          def parse_possible_parts
            max_value = 4000
            accepted = []
            part_ranges = [{ workflow: "in",
                             attr: { x: { start: 1, end: max_value }, m: { start: 1, end: max_value }, a: { start: 1, end: max_value },
                                     s: { start: 1, end: max_value } } }]
            until part_ranges.empty?
              new_ranges = []
              part_ranges.each do |part_range|
                # puts "part_range: #{part_range.inspect}"
                ranges = put_part_range_through_workflow(part_range[:attr], part_range[:workflow])
                ranges.each do |range|
                  if range[:workflow] == "A"
                    accepted << range
                  elsif range[:workflow] != "R"
                    new_ranges << range
                  end
                end
              end
              part_ranges = new_ranges
            end
            accepted
          end

          def put_part_range_through_workflow(part_attrs, workflow)
            workflow = @workflows[workflow]
            # puts workflow.inspect
            new_ranges = []
            current_attr = part_attrs.dup
            workflow.each do |rule|
              if rule.is_a? String
                new_ranges << { workflow: rule, attr: current_attr }
              else
                accepted, ignored = split_range(rule, current_attr)
                new_ranges << { workflow: rule[:destination], attr: accepted } if accepted
                current_attr = ignored
                break unless ignored
              end
            end
            new_ranges
          end

          def split_range(rule, attr_range) # rubocop:disable Metrics/AbcSize
            logger.debug { "Split range: rule:#{rule}, attr_range: #{attr_range.inspect}" }
            if rule[:check] == ">"
              if attr_range[rule[:attr]][:start] > rule[:value]
                # All get passed through
                [attr_range, nil]
              elsif attr_range[rule[:attr]][:end] <= rule[:value]
                # None get passed through
                [nil, attr_range]
              else
                rstart = attr_range[rule[:attr]][:start]
                rend = attr_range[rule[:attr]][:end]
                rmid = rule[:value]
                [
                  attr_range.merge({ rule[:attr] => { start: rmid + 1, end: rend } }),
                  attr_range.merge({ rule[:attr] => { start: rstart, end: rmid } })
                ]
              end
            elsif attr_range[rule[:attr]][:end] < rule[:value]
              [attr_range, nil]
            # All get passed through
            elsif attr_range[rule[:attr]][:start] >= rule[:value]
              # None get passed through
              [nil, attr_range]
            else
              rstart = attr_range[rule[:attr]][:start]
              rend = attr_range[rule[:attr]][:end]
              rmid = rule[:value]
              [
                attr_range.merge({ rule[:attr] => { start: rstart, end: rmid - 1 } }),
                attr_range.merge({ rule[:attr] => { start: rmid, end: rend } })
              ]
            end
          end

          def put_part_through_workflow(part, workflow)
            die "Couldn't find workflow #{workflow}" unless @workflows[workflow]
            @workflows[workflow].each do |rule|
              return parse_destination(part, rule) if rule.is_a? String

              if rule[:check] == ">"
                return parse_destination(part, rule[:destination]) if part[rule[:attr]] > rule[:value]
              elsif part[rule[:attr]] < rule[:value]
                return parse_destination(part, rule[:destination])
              end
            end
          end

          def parse_destination(part, destination)
            if destination == "A" then true
            elsif destination == "R" then false
            else
              put_part_through_workflow(part, destination)
            end
          end

          def star_one
            accepted = parse_parts
            total = accepted.map(&:values).flatten.sum
            logger.warn "Star one answer: #{total}"
          end

          def star_two
            accepted = parse_possible_parts
            logger.warn "Star two answer: #{calculate_total_from_ranges(accepted)}"
          end

          def calculate_total_from_ranges(ranges)
            total = 0
            ranges.each do |range|
              permutations = range[:attr].values.map { |v| v[:end] + 1 - v[:start] }.inject(1) { |x, y| x * y }
              total += permutations
            end
            total
          end
        end
      end
    end
  end
end
