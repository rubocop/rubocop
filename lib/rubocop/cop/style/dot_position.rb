# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the . position in multi-line method calls.
      class DotPosition < Cop
        MSG = 'Place the . on the next line, together with the method name.'

        def on_send(node)
          return unless node.loc.dot

          add_offence(node, :dot) unless proper_dot_position?(node)
        end

        private

        def proper_dot_position?(node)
          dot_line = node.loc.dot.line

          if node.loc.selector
            selector_line = node.loc.selector.line
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            selector_line = node.loc.begin.line
          end

          case cop_config['Style'].downcase
          when 'leading' then dot_line == selector_line
          when 'trailing' then dot_line != selector_line || same_line?(node)
          else fail 'Unknown dot position style selected.'
          end
        end

        def same_line?(node)
          node.loc.dot.line == node.loc.line
        end
      end
    end
  end
end
