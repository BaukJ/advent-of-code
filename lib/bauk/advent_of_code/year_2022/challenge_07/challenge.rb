# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge07
        # Challenge for 2022/07
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            # @data = {dirs: {}, size: 0}
            @dirs = {}
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            @current_path = "/"
            @lines.each do |line|
              parse_line line
            end
            # puts(@dirs.select { |dir, details| details[:size] <= 400_000 }.map {|k,v| [k, v[:size]] })
            selected = @dirs.select { |_dir, details| details[:size] <= 100_000 }
            total = selected.values.inject(0) { |t, d| t + d[:size] }
            logger.warn "Total: #{total}"
            part_two
          end

          def part_two
            total_size = 70_000_000
            required_size = 30_000_000
            free_space = total_size - @dirs["/"][:size]
            to_delete = required_size - free_space
            selected = @dirs.select { |_dir, details| details[:size] >= to_delete }.min_by { |_k, v| v[:size] }
            logger.warn "To delete: #{selected[1][:size]}"
          end

          def parse_line(line)
            case line
            when /^\$ cd (.*)$/
              cd = $1
              logger.info { "#{@current_path} -> cd '#{cd}'" }
              case cd
              when ".." then @current_path.sub! %r{/[^/]*$}, ""
              when "/" then @current_path = "/"
              else
                @current_path += "/" unless @current_path =~ %r{/$}
                @current_path += cd
              end
            when /^\$ ls$/
              logger.debug { "#{@current_path} -> ls" }
            when /^dir (.*)$/
              logger.debug { "#{@current_path} -> found dir: #{$1}" }
            when /^([0-9]+) (.*)$/
              parse_file $2, $1.to_i
            else
              die "Invalid line #{line}"
            end
            # logger.debug @dirs
            # sleep 1
          end

          def parse_file(file, size)
            logger.debug { "#{@current_path} -> found file: #{file} (size: #{size})" }
            # @current_path.split("/").reject(&:empty?).inject(@data) do |data, item|
            #   data[:dirs][item] ||= {size: 0, dirs: {}}
            #   data[:size] += size
            #   data[:dirs][item]
            # end[:size] += size
            full_path = "#{@current_path}/#{file}"
            @current_path.split("/").inject("") do |path, item|
              path += "/" unless path =~ %r{/$}
              path += item
              @dirs[path] ||= { files: {}, size: 0 }
              unless @dirs[path][:files][full_path]
                @dirs[path][:size] += size
                @dirs[path][:files][full_path] = true
              end
              path
            end
          end

          def flat_data(data = @data)
            flat = {}
            data[:dirs]
            flat
          end
        end
      end
    end
  end
end
