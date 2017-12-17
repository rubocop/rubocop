# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects string literals
    class StringLiteralCorrector
      extend Util

      class << self
        def correct(node, style)
          return if node.dstr_type?

          lambda do |corrector|
            str = node.str_content
            if style == :single_quotes
              corrector.replace(node.source_range, to_string_literal(str))
            else
              corrector.replace(node.source_range, str.inspect)
            end
          end
        end
      end
    end
  end
end
