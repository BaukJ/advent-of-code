# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2022
      module Challenge1
        Opts = Struct.new(:map_file)
                     .new("map.txt")

        module Options
          def self.parse(opts)
            opts.on("--map-file=FILE") do |file|
              Opts.map_file = file
            end
          end
        end
      end
    end
  end
end
