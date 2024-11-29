# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge07
        Opts = Struct.new(:file, :show, :sleep, :star)
                     .new("data.txt", false, 1, 0)
      end
    end
  end
end
