# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge13
        # Map for 2023/13
        class Map < BaseMap
          def self.cell_from_char(char, _row, _column)
            case char
            when "." then false
            when "#" then true
            else die "Invalid char: '#{char}'"
            end
          end

          def cell_to_s(cell, _row_index, _column_index)
            cell ? "#" : "."
          end
        end
      end
    end
  end
end
