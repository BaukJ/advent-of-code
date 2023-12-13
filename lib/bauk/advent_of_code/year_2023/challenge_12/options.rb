# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge12
        Opts = Struct.new(:file, :max_section_length, :rows, :expand)
                     .new("data.txt", 5, 0, 5)
      end
    end
  end
end
