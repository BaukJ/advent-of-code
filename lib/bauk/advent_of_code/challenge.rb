require_relative "base_class"

module Bauk
  module AdventOfCode
    class Challenge < BaseClass
      def run
        logger.info "Running challenge: #{self.class}"
      end
    end
  end
end
