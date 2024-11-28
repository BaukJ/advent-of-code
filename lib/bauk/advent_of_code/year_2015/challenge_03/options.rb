# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge03
        Opts = Struct.new(:file, :show, :star, :sleep)
                     .new("data.txt", false, 0, 1)
      end
    end
  end
end
