# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge17
        Opts = Struct.new(:file, :min_heat_loss)
                     .new("data.txt", 0)
      end
    end
  end
end
