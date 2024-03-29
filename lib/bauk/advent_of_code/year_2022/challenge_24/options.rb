# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge24
        Opts = Struct.new(:max_steps, :map_file, :show, :show_map_sleep, :show_final_map, :booleanize)
                     .new(500, "challenge_24.txt", false, 0.5, false, false)
      end
    end
  end
end
