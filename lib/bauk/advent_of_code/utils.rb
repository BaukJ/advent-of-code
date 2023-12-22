# frozen_string_literal: true

module Bauk
  module AdventOfCode
    module Utils
      PRETTY_CACHE = true

      def self.bidirectional_range(x, y)
        if x < y
          (x...y).to_a
        else
          (y...x).to_a.reverse
        end
      end

      def self.inclusive_bidirectional_range(x, y)
        if x < y
          (x..y).to_a
        else
          (y..x).to_a.reverse
        end
      end

      def self.cache(id, symbolize_names: true)
        file = File.expand_path("../../../cache/#{id}.json", __dir__)
        dir = File.expand_path("..", file)
        FileUtils.mkdir_p dir
        if File.exist? file
          Logger.static.warn "Loading cache: #{id}"
          data = JSON.load_file file, symbolize_names:
        else
          Logger.static.warn "Generating cache: #{id} (pretty: #{PRETTY_CACHE})"
          data = yield
          File.write file, PRETTY_CACHE ? JSON.pretty_generate(data) : JSON.dump(data)
        end
        data
      end

      def self.cache_save(id, data)
        file = File.expand_path("../../../cache/#{id}.json", __dir__)
        dir = File.expand_path("..", file)
        FileUtils.mkdir_p dir
        File.write file, PRETTY_CACHE ? JSON.pretty_generate(data) : JSON.dump(data)
        Logger.static.warn "Saved cache: #{id} (pretty: #{PRETTY_CACHE})"
      end
    end
  end
end

# Monkey-patch integer to be able to pretty print with underscores
class Integer
  def underscore
    to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1_")
  end
end

class Array
  def deep_clone
    map do |v|
      if v.respond_to? :deep_clone
        v.deep_clone
      else
        v.clone
      end
    end
  end
end

class Hash
  def deep_clone
    map do |k,v|
      if v.respond_to? :deep_clone
        [k, v.deep_clone]
      else
        [k, v.clone]
      end
    end.to_h
  end
end
