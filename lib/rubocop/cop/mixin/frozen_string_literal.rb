# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for dealing with frozen string literals.
    module FrozenStringLiteral
      module_function

      FROZEN_STRING_LITERAL = '# frozen_string_literal:'.freeze
      FROZEN_STRING_LITERAL_ENABLED = '# frozen_string_literal: true'.freeze
      FROZEN_STRING_LITERAL_TYPES = %i[str dstr].freeze

      def frozen_string_literal_comment_exists?
        leading_comment_lines.any? do |line|
          MagicComment.parse(line).frozen_string_literal_specified?
        end
      end

      private

      def frozen_string_literals_enabled?
        ruby_version = processed_source.ruby_version
        return false unless ruby_version
        # TODO: Frozen string literal will be default in Ruby 3.0
        # or not yet determinable.
        # It is necessary to change according to trend in the future.
        # https://bugs.ruby-lang.org/issues/8976#note-41
        return true if ruby_version >= 3.0
        return false unless ruby_version >= 2.3

        leading_comment_lines.any? do |line|
          MagicComment.parse(line).frozen_string_literal?
        end
      end

      def leading_comment_lines
        processed_source[0..2].compact
      end
    end
  end
end
