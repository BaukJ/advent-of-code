# frozen_string_literal: true

require_relative "base_class"

module Bauk
  module AdventOfCode
    # Base class for all challenges
    class BaseChallenge < BaseClass
      def run
        logger.info "Running challenge: #{self.class}"
      end
    end
  end
end
