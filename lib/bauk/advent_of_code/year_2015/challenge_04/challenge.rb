# frozen_string_literal: true

require_relative "../../base_challenge"
require "digest"

module Bauk
  module AdventOfCode
    module Year2015
      module Challenge04
        # Challenge for 2015/04
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one if [0, 1].include? Opts.star
            star_two if [0, 2].include? Opts.star
          end

          def star_one
            num = -1
            input = "iwrupvqb"
            md5 = Digest::MD5.new
            loop do
              num += 1
              md5.reset
              md5 << input
              md5 << num.to_s
              puts "#{num} => #{md5.hexdigest}" if md5.hexdigest.start_with? "000"
              break if md5.hexdigest.start_with? "00000"
            end
            logger.warn "Star one answer: #{num}"
          end

          def star_two
            num = -1
            input = "iwrupvqb"
            md5 = Digest::MD5.new
            loop do
              num += 1
              md5.reset
              md5 << input
              md5 << num.to_s
              puts "#{num} => #{md5.hexdigest}" if md5.hexdigest.start_with? "00000"
              break if md5.hexdigest.start_with? "000000"
            end
            logger.warn "Star two answer: #{num}"
          end
        end
      end
    end
  end
end
