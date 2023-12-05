# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge22
        Opts = Struct.new(:file, :show_map)
                     .new("data.txt", false)
      end
    end
  end
end
