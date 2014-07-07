# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %W() syntax when %w() would do.
      class UnneededCapitalW < Cop
        include PercentLiteral

        MSG =
          'Do not use `%W` unless interpolation is needed.  If not, use `%w`.'

        def on_array(node)
          process(node, '%W')
        end

        private

        def on_percent_literal(node)
          return unless node.children.none? { |x| x.type == :dstr }

          add_offense(node, :expression)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, '%w(')
          end
        end
      end
    end
  end
end
