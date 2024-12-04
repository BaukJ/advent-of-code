# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge23
        # Challenge for 2023/23
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            @map = Map.from_lines @lines
            @row = 0
            @column = 1
            @been = { "#{@row}_#{@column}" => true }
          end

          def walk(row, column, been = {})
            show_map been
            if row == @map.row_max_index && (column = @map.column_max_index - 1)
              logger.info "FINISHED in #{been.length} steps"
              @longest = been.length if been.length > @longest
              return
            end
            # puts been.length
            been = been.merge({ "#{row}_#{column}" => { row:, column: } })
            # been["#{row}_#{column}"] = {row:, column:}
            current_cell = @map.cell row, column
            if current_cell.empty? then possible_cells = @map.adjacent_4_cells_with_row_column(row, column)
            elsif current_cell == [">"] then possible_cells = [@map.cell_with_row_column(row, column + 1)]
            elsif current_cell == ["<"] then possible_cells = [@map.cell_with_row_column(row, column - 1)]
            elsif current_cell == ["^"] then possible_cells = [@map.cell_with_row_column(row - 1, column)]
            elsif current_cell == ["v"] then possible_cells = [@map.cell_with_row_column(row + 1, column)]
            else
              die "ERR!"
            end
            possible_cells.each do |cell, r, c|
              next if been["#{r}_#{c}"]

              walk(r, c, been) if cell.empty? || %w[> < v ^].include?(cell[0])
            end
          end

          def walk2(row, column, been = {})
            @been_paths = {}
            if row == @map.row_max_index && (column = @map.column_max_index - 1)
              show_map been
              logger.info "FINISHED in #{been.length} steps"
              @longest = been.length if been.length > @longest
              been.each do |k, v|
                @been_paths[k] = v if @been_paths[k].nil? || v[:length] > @been_paths[k][:length]
              end
              return
            end
            key = "#{row}_#{column}"
            return if @been_paths[key] && @been_paths[key][:length] > been.length

            # puts been.length
            been = been.merge({ key => { row:, column:, length: been.length } })
            # been["#{row}_#{column}"] = {row:, column:}
            possible_cells = @map.adjacent_4_cells_with_row_column(row, column)
            @paths += possible_cells.length
            possible_cells.each do |cell, r, c|
              @paths -= 1
              # puts @paths
              next if been["#{r}_#{c}"]

              walk2(r, c, been) if cell.empty? || %w[> < v ^].include?(cell[0])
            end
          end

          def walk3(row, column)
            @been_paths = {}
            paths = [{ been: {}, row:, column: }]
            step = 0
            until paths.empty?
              step += 1
              new_paths = []
              logger.warn { "#{step}) #{paths.length}" }
              paths.each do |path|
                # show_map path[:been]
                if path[:row] == @map.row_max_index && (path[:column] = @map.column_max_index - 1)
                  # show_map been
                  logger.info "FINISHED in #{path[:been].length} steps"
                  @longest = path[:been].length if path[:been].length > @longest
                  # been.each do |k, v|
                  #   @been_paths[k] = v if @been_paths[k].nil? || v[:length] > @been_paths[k][:length]
                  # end
                  next
                end
                key = "#{path[:row]}_#{path[:column]}"
                # next if @been_paths[key] && @been_paths[key][:length] > been.length
                # puts been.length
                been = path[:been].merge({ key => { row: path[:row], column: path[:column], length: path[:been].length } })
                possible_cells = @map.adjacent_4_cells_with_row_column(path[:row], path[:column])
                possible_cells.each do |cell, r, c|
                  next if been["#{r}_#{c}"]

                  new_paths << ({ row: r, column: c, been: }) if cell.empty? || %w[> < v ^].include?(cell[0])
                end
              end

              paths = new_paths
              # Filter paths
              # paths = []
              # new_paths.each do |path|
              #   paths << path unless paths.select { |p| p[:row] == path[:row] && p[:column] == path[:column] }.any?
              # end
            end
          end

          def walk4(row, column) # rubocop:disable Metrics/AbcSize
            paths = { "#{row}_#{column}" => { beens: [{ "" => true }], row:, column: } }
            step = -1
            until paths.empty? # || step > 1200
              step += 1
              new_paths = {}
              logger.warn { "#{step}) #{paths.length} (#{paths.map { |_k, v| v[:beens].length }.sum})" }
              # logger.warn { "#{step}) #{paths.length}" }
              paths.each do |key, path|
                show_map({ a: { row: path[:row], column: path[:column] } })
                if path[:row] == @map.row_max_index && path[:column] == @map.column_max_index - 1
                  logger.info "FINISHED in #{step} steps"
                  @longest = step
                  next
                end
                possible_cells = @map.adjacent_4_cells_with_row_column(path[:row], path[:column])
                possible_cells.each do |cell, r, c|
                  next unless cell.empty? # || %w[> < v ^].include?(cell[0])

                  new_key = "#{r}_#{c}"
                  path[:beens].each do |been|
                    next if been[new_key]

                    new_paths[new_key] ||= { row: r, column: c, beens: [] }

                    new_paths[new_key][:beens] << been.merge({ key => true })
                  end
                end
              end

              new_paths.each do |_key, path|
                path[:beens].uniq! { |been| been.keys.sort.join }
              end

              paths = new_paths
              # Filter paths
              # paths = []
              # new_paths.each do |path|
              #   paths << path unless paths.select { |p| p[:row] == path[:row] && p[:column] == path[:column] }.any?
              # end
            end
          end

          def walk5(row, column) # rubocop:disable Metrics/AbcSize
            parse_nodes
            puts @nodes
            @nodes.each do |k, v|
              puts k
              puts v
            end
            @longest = 0
            round = 0
            paths = { "#{row}_#{column}" => { been: { "" => true }, row:, column:, steps: 0 } }
            until paths.empty?
              round += 1
              new_paths = []

              logger.warn { "#{round}) #{paths.length}" }
              # logger.warn { "#{step}) #{paths.length}" }
              paths.each do |key, path|
                # puts path.inspect
                # show_map({a: {row: path[:row], column: path[:column]}})
                @nodes[key][:dests].each do |dest_key, dest|
                  next if path[:been][dest_key]

                  if dest[:row] == @map.row_max_index
                    total = path[:steps] + dest[:steps]
                    @longest = total if total > @longest
                    next
                  end

                  # puts
                  # puts @map.row_max_index
                  # puts dest.inspect
                  # puts path.inspect
                  new_paths << [dest_key, { been: path[:been].merge({ key => true }), row: dest[:row], column: dest[:column], steps: path[:steps] + dest[:steps] }]
                end
              end

              paths = new_paths
              # Filter paths
              # paths = []
              # new_paths.each do |path|
              #   paths << path unless paths.select { |p| p[:row] == path[:row] && p[:column] == path[:column] }.any?
              # end
            end
          end

          def parse_nodes
            puts "Parsing"
            @nodes = {}
            @map.cells_with_row_column.each do |cell, row, column|
              # puts "#{row}/#{column}"
              next unless cell.empty?

              key = "#{row}_#{column}"
              adjacents = @map.adjacent_4_cells_with_row_column(row, column).select { |c, _, _| c.empty? }
              @nodes[key] = { row:, column:, dests: parse_node(row, column, adjacents) } if adjacents.length > 2 || row.zero?
            end
          end

          def parse_node(start_row, start_column, adjacents)
            dests = {}
            adjacents.each do |_cell, row, column|
              # puts "#{row}/#{column}"
              been = { "#{start_row}_#{start_column}" => true }
              steps = 0
              loop do
                steps += 1
                been["#{row}_#{column}"] = true
                adjacents = @map.adjacent_4_cells_with_row_column(row, column).select { |c, ro, co| c.empty? && !been["#{ro}_#{co}"] }

                if adjacents.empty? && row != @map.row_max_index
                  break
                elsif adjacents.length == 1
                  row = adjacents[0][1]
                  column = adjacents[0][2]
                else
                  die "Two paths between nodes" if dests["#{row}_#{column}"]
                  dests["#{row}_#{column}"] = {
                    row:,
                    column:,
                    steps:
                  }
                  break
                end
              end
            end
            dests
          end

          def show_map(been)
            map = @map.deep_clone
            been.each do |_, v|
              # puts v.inspect
              map.insert v[:row], v[:column], "*"
            end
            puts map
            sleep 0.5
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            # star_one
            star_two
          end

          def star_one
            @longest = 0
            walk @row, @column
            logger.warn "Star one answer: #{@longest}"
          end

          def star_two
            @paths = 0
            @longest = 0
            @map.cells.each do |cell|
              cell.pop if %w[^ v > <].include? cell[0]
            end
            walk5 @row, @column
            logger.warn "Star two answer: #{@longest}"
          end
        end
      end
    end
  end
end

# too low: 4978
