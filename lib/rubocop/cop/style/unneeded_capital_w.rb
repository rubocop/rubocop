# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %W() syntax when %w() would do.
      class UnneededCapitalW < Cop
        include PercentLiteral

        MSG = 'Do not use `%W` unless interpolation is needed. ' \
              'If not, use `%w`.'.freeze

        def on_array(node)
          process(node, '%W')
        end

        private

        def on_percent_literal(node)
          requires_interpolation = node.children.any? do |string|
            string.type == :dstr ||
              double_quotes_acceptable?(string.str_content)
          end
          add_offense(node, :expression) unless requires_interpolation
        end

        def autocorrect(node)
          lambda do |corrector|
            src = node.loc.begin.source
            corrector.replace(node.loc.begin, src.tr('W', 'w'))
          end
        end
      end
    end
  end
end
