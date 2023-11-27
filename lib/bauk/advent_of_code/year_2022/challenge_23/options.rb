# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge23
        Opts = Struct.new(:file, :show_map, :rounds)
                     .new("data.txt", false, 0)
      end
    end
  end
end
