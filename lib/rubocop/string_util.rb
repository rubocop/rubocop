# encoding: utf-8

module RuboCop
  # This module provides approximate string matching methods.
  module StringUtil
    module_function

    def similarity(string_a, string_b)
      JaroWinkler.distance(string_a.to_s, string_b.to_s)
    end

    # This class computes Jaro distance, which is a measure of similarity
    # between two strings.
    class Jaro
      attr_reader :shorter, :longer

      def self.distance(a, b)
        new(a, b).distance
      end

      def initialize(a, b)
        if a.size < b.size
          @shorter, @longer = a, b
        else
          @shorter, @longer = b, a
        end
      end

      def distance
        @distance ||= compute_distance
      end

      private

      def compute_distance
        common_chars_a, common_chars_b = find_common_characters
        matching_count = common_chars_a.size

        return 0.0 if matching_count.zero?

        transposition_count =
          count_transpositions(common_chars_a, common_chars_b)

        sum = (matching_count / shorter.size.to_f) +
              (matching_count / longer.size.to_f) +
              ((matching_count - transposition_count / 2) / matching_count.to_f)

        sum / 3.0
      end

      def find_common_characters
        common_chars_of_shorter = []
        common_chars_of_longer = []

        # In Ruby 1.9 String#chars returns Enumerator rather than Array.
        longer_chars = longer.each_char.to_a

        shorter.each_char.with_index do |shorter_char, shorter_index|
          matching_range(shorter_index).each do |longer_index|
            longer_char = longer_chars[longer_index]

            next unless shorter_char == longer_char

            common_chars_of_shorter[shorter_index] = shorter_char
            common_chars_of_longer[longer_index] = longer_char

            # Mark the matching character as already used
            longer_chars[longer_index] = nil

            break
          end
        end

        [common_chars_of_shorter, common_chars_of_longer].map(&:compact)
      end

      def count_transpositions(common_chars_a, common_chars_b)
        common_chars_a.size.times.count do |index|
          common_chars_a[index] != common_chars_b[index]
        end
      end

      def matching_range(origin)
        min = origin - matching_window
        min = 0 if min < 0

        max = origin + matching_window

        min..max
      end

      def matching_window
        @match_window ||= (longer.size / 2).to_i - 1
      end
    end

    # This class computes Jaro-Winkler distance, which adds prefix-matching
    # bonus to Jaro distance.
    class JaroWinkler
      # Add the prefix bonus only when the Jaro distance is above this value.
      # In other words, if the Jaro distance is less than this value,
      # JaroWinkler.distance returns the raw Jaro distance.
      DEFAULT_BOOST_THRESHOLD = 0.7

      # How much the prefix bonus is weighted.
      # This should not exceed 0.25.
      DEFAULT_SCALING_FACTOR = 0.1

      # Cutoff the common prefix length to this value if it's longer than this.
      MAX_COMMON_PREFIX = 4

      attr_reader :boost_threshold, :scaling_factor

      def self.distance(a, b, boost_threshold = nil, scaling_factor = nil)
        new(a, b, boost_threshold, scaling_factor).distance
      end

      def initialize(a, b, boost_threshold = nil, scaling_factor = nil)
        @jaro = Jaro.new(a, b)
        @boost_threshold = boost_threshold || DEFAULT_BOOST_THRESHOLD
        @scaling_factor = scaling_factor || DEFAULT_SCALING_FACTOR
      end

      def distance
        if @jaro.distance >= boost_threshold
          bonus = limited_common_prefix_length.to_f * scaling_factor.to_f *
                  (1.0 - @jaro.distance)
          @jaro.distance + bonus
        else
          @jaro.distance
        end
      end

      def shorter
        @jaro.shorter
      end

      def longer
        @jaro.longer
      end

      private

      def limited_common_prefix_length
        length = common_prefix_length

        if length > MAX_COMMON_PREFIX
          MAX_COMMON_PREFIX
        else
          length
        end
      end

      def common_prefix_length
        shorter.size.times do |index|
          return index unless shorter[index] == longer[index]
        end

        shorter.size
      end
    end
  end
end
