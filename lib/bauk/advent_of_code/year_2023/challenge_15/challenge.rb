# frozen_string_literal: true

require_relative "../../base_challenge"

module Bauk
  module AdventOfCode
    module Year2023
      module Challenge15
        # Challenge for 2023/15
        class Challenge < BaseChallenge
          def initialize
            super
            @lines = File.readlines File.join(__dir__, Opts.file), chomp: true
            die "ERR" if @lines[1]
            @sequences = @lines[0].split(",")
          end

          def run
            logger.warn("Starting challenge #{self.class.name}")
            star_one
            star_two
          end

          def seq_to_hash(seq)
            hash = 0
            seq.chars.each do |char|
              hash += char.ord
              hash *= 17
              hash %= 256
            end
            logger.info "SEQ to HASH) #{seq} => #{hash}"
            hash
          end

          def star_one
            @hashes = []
            @sequences.each do |seq|
              @hashes << seq_to_hash(seq)
            end
            logger.warn "Star one answer: #{@hashes.sum}"
          end

          def star_two
            @hashes = []
            @boxes = {}
            @sequences.each do |code|
              die "ERR" unless code =~ /^(.*)([=-])([0-9]*)$/
              seq = $1
              hash = seq_to_hash(seq)
              command = $2
              lens = $3.to_i
              box = @boxes[hash] ||= { map: {}, list: [] }

              case command
              when "="
                box[:list] << seq unless box[:map][seq]
                box[:map][seq] = lens
              when "-"
                if box[:map][seq]
                  box[:map].delete(seq)
                  box[:list].delete(seq)
                end
              else
                die "ERR"
              end
              # puts @boxes.inspect
              # @hashes << seq_to_hash(seq)
            end
            @total = 0
            @boxes.each do |box_number, box|
              box[:list].each_with_index do |seq, slot_index|
                power = (box_number + 1) * (slot_index + 1) * box[:map][seq]
                logger.debug { "#{box_number}->#{slot_index}->#{box[:map][seq]} => #{power}" }
                @total += power
              end
            end
            logger.warn "Star two answer: #{@total}"
          end
        end
      end
    end
  end
end
