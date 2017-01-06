# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %Q() syntax when %q() would do.
      class PercentQLiterals < Cop
        include PercentLiteral
        include ConfigurableEnforcedStyle

        LOWER_CASE_Q_MSG = 'Do not use `%Q` unless interpolation is ' \
                           'needed.  Use `%q`.'.freeze
        UPPER_CASE_Q_MSG = 'Use `%Q` instead of `%q`.'.freeze

        def on_str(node)
          process(node, '%Q', '%q')
        end

        private

        def on_percent_literal(node)
          return if correct_literal_style?(node)

          # Report offense only if changing case doesn't change semantics,
          # i.e., if the string would become dynamic or has special characters.
          return if node.children != parse(corrected(node.source)).ast.children

          add_offense(node, :begin, message)
        end

        def correct_literal_style?(node)
          style == :lower_case_q && type(node) == '%q' ||
            style == :upper_case_q && type(node) == '%Q'
        end

        def message
          style == :lower_case_q ? LOWER_CASE_Q_MSG : UPPER_CASE_Q_MSG
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, corrected(node.source))
          end
        end

        def corrected(src)
          src.sub(src[1], src[1].swapcase)
        end
      end
    end
  end
end
