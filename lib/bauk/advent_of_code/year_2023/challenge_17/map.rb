# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge17
        # Map for 2023/17
        class Map < BaseMap
          def self.cell_from_char(char, _row, _column)
            char.to_i
          end
        end
      end
    end
  end
end
