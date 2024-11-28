# frozen_string_literal: true

require_relative "../../base_map"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge03
        # Map for 2015/03
        class Map < BaseMap
          def generate_cell(_row_index, _column_index)
            [0]
          end
        end
      end
    end
  end
end
