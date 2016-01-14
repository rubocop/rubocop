# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for dealing with frozen string literals.
    module FrozenStringLiteral
      module_function

      FROZEN_STRING_LITERAL = '# frozen_string_literal:'.freeze
      FROZEN_STRING_LITERAL_ENABLED = '# frozen_string_literal: true'.freeze
      FROZEN_STRING_LITERAL_TYPES = [:str, :dstr].freeze

      def frozen_string_literal_comment_exists?(processed_source,
                                                comment = FROZEN_STRING_LITERAL)
        first_three_lines =
          [processed_source[0], processed_source[1], processed_source[2]]
        first_three_lines.compact!
        first_three_lines.any? do |line|
          line.start_with?(comment)
        end
      end

      def frozen_string_literals_enabled?(processed_source)
        ruby_version = processed_source.ruby_version
        return false unless ruby_version
        return true if ruby_version >= 3.0
        return false unless ruby_version >= 2.3
        frozen_string_literal_comment_exists?(
          processed_source, FROZEN_STRING_LITERAL_ENABLED
        )
      end
    end
  end
end
