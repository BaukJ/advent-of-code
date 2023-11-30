# frozen_string_literal: true

module Bauk
  module AdventOfCode
    module Utils
      def self.bidirectional_range(x, y)
        if x < y
          (x...y).to_a
        else
          (y...x).to_a.reverse
        end
      end

      def self.inclusive_bidirectional_range(x, y)
        if x < y
          (x..y).to_a
        else
          (y..x).to_a.reverse
        end
      end
    end
  end
end
