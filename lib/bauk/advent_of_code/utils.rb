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

      def self.cache(id, symbolize_names: true)
        file = "#{File.join(__dir__, "..", "..", "..", id)}.json"
        if File.exist? file
          data = JSON.load_file file, symbolize_names:
        else
          data = yield
          File.write file, JSON.dump(data)
        end
        data
      end
    end
  end
end

# Monkey-patch integer to be able to pretty print with underscores
class Integer
  def underscore
    to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1_")
  end
end
