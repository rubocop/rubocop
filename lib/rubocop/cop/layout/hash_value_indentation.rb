# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # The value of a hash pair should be indented relative to its key
      # when the key and the value is not on the same line.
      # Note that this cop inspects code only when 'Layout/HashAlignment' is configured
      # with 'key' style combined with no other styles (since the cop allows multiple styles).
      #
      # @example
      #   # bad
      #   {
      #     key:
      #     value
      #   }
      #
      #   {
      #     key:
      #   value
      #   }
      #
      #   {
      #     key:
      #          value
      #   }
      #
      #   # good
      #   {
      #     key:
      #       value
      #   }
      #
      class HashValueIndentation < Base
        include Alignment
        extend AutoCorrector

        MSG = 'Indent the hash value relative to its key.'

        def on_pair(node)
          separator = node.colon? ? :colon : :hash_rocket
          return unless compatible_hash_alignment_style_for?(separator)

          key = node.key
          val = node.value
          return if same_line?(key, val)

          expected_column = key.loc.column + configured_indentation_width
          return if valid_indentation?(val, expected_column)

          register_offense(val, expected_column)
        end

        private

        def register_offense(val, expected_column)
          add_offense(val) do |corrector|
            column_delta = expected_column - val.loc.column
            AlignmentCorrector.correct(corrector, processed_source, val, column_delta)
          end
        end

        def valid_indentation?(val, expected_column)
          val.loc.column == expected_column
        end

        def compatible_hash_alignment_style_for?(separator)
          hash_alignment_config = config['Layout/HashAlignment']

          hash_alignment_style = if separator == :colon
                                   hash_alignment_config['EnforcedColonStyle']
                                 else
                                   hash_alignment_config['EnforcedHashRocketStyle']
                                 end

          [['key'], [nil]].include?(Array(hash_alignment_style))
        end
      end
    end
  end
end
