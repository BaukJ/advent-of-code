# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge17
        Opts = Struct.new(:file, :min_heat_loss, :show_map)
                     .new("data.txt", 0, false)
      end
    end
  end
end
