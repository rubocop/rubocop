# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %Q() syntax when %q() would do.
      class PercentQLiterals < Cop
        include PercentLiteral
        include ConfigurableEnforcedStyle

        def on_str(node)
          process(node, '%Q', '%q')
        end

        private

        def on_percent_literal(node)
          if style == :lower_case_q
            if type(node) == '%Q'
              check(node,
                    'Do not use `%Q` unless interpolation is needed.  ' \
                    'Use `%q`.')
            end
          elsif type(node) == '%q'
            check(node, 'Use `%Q` instead of `%q`.')
          end
        end

        def check(node, msg)
          # Report offense only if changing case doesn't change semantics,
          # i.e., if the string would become dynamic or has special characters.
          return if node.children != parse(corrected(node.source)).ast.children

          add_offense(node, :begin, msg)
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
