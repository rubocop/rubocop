# frozen_string_literal: true

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

      def self.distance(*args)
        new(*args).distance
      end

      def initialize(string_a, string_b)
        if string_a.size < string_b.size
          @shorter = string_a
          @longer = string_b
        else
          @shorter = string_b
          @longer = string_a
        end
      end

      def distance
        @distance ||= compute_distance
      end

      private

      def compute_distance
        common_chars_a, common_chars_b = find_common_characters
        matched_count = common_chars_a.size

        return 0.0 if matched_count.zero?

        transposition_count =
          count_transpositions(common_chars_a, common_chars_b)

        compute_non_zero_distance(matched_count.to_f, transposition_count)
      end

      # rubocop:disable Metrics/AbcSize
      def find_common_characters
        common_chars_of_shorter = Array.new(shorter.size)
        common_chars_of_longer = Array.new(longer.size)

        shorter.each_char.with_index do |shorter_char, shorter_index|
          matching_index_range(shorter_index).each do |longer_index|
            longer_char = longer.chars[longer_index]

            next unless shorter_char == longer_char

            common_chars_of_shorter[shorter_index] = shorter_char
            common_chars_of_longer[longer_index] = longer_char

            # Mark the matching character as already used
            longer.chars[longer_index] = nil

            break
          end
        end

        [common_chars_of_shorter, common_chars_of_longer].map(&:compact)
      end
      # rubocop:enable Metrics/AbcSize

      def count_transpositions(common_chars_a, common_chars_b)
        common_chars_a.size.times.count do |index|
          common_chars_a[index] != common_chars_b[index]
        end
      end

      def compute_non_zero_distance(matched_count, transposition_count)
        sum = (matched_count / shorter.size.to_f) +
              (matched_count / longer.size.to_f) +
              ((matched_count - transposition_count / 2) / matched_count)

        sum / 3.0
      end

      def matching_index_range(origin)
        min = origin - matching_window
        min = 0 if min < 0

        max = origin + matching_window

        min..max
      end

      def matching_window
        @matching_window ||= (longer.size / 2).to_i - 1
      end
    end

    # This class computes Jaro-Winkler distance, which adds prefix-matching
    # bonus to Jaro distance.
    class JaroWinkler < Jaro
      # Add the prefix bonus only when the Jaro distance is above this value.
      # In other words, if the Jaro distance is less than this value,
      # JaroWinkler.distance returns the raw Jaro distance.
      DEFAULT_BOOST_THRESHOLD = 0.7

      # How much the prefix bonus is weighted.
      # This should not exceed 0.25.
      DEFAULT_SCALING_FACTOR = 0.1

      # Cutoff the common prefix length to this value if it's longer than this.
      MAX_COMMON_PREFIX_LENGTH = 4

      attr_reader :boost_threshold, :scaling_factor

      def initialize(string_a, string_b,
                     boost_threshold = nil, scaling_factor = nil)
        super(string_a, string_b)
        @boost_threshold = boost_threshold || DEFAULT_BOOST_THRESHOLD
        @scaling_factor = scaling_factor || DEFAULT_SCALING_FACTOR
      end

      private

      def compute_distance
        jaro_distance = super

        if jaro_distance >= boost_threshold
          bonus = limited_common_prefix_length.to_f * scaling_factor.to_f *
                  (1.0 - jaro_distance)
          jaro_distance + bonus
        else
          jaro_distance
        end
      end

      def limited_common_prefix_length
        length = common_prefix_length

        if length > MAX_COMMON_PREFIX_LENGTH
          MAX_COMMON_PREFIX_LENGTH
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
