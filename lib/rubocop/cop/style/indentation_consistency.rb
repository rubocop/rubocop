# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks for inconsistent indentation.
      #
      # @example
      #
      #   class A
      #     def test
      #       puts 'hello'
      #        puts 'world'
      #     end
      #   end
      class IndentationConsistency < Cop
        include AutocorrectAlignment
        include AccessModifierNode

        MSG = 'Inconsistent indentation detected.'

        def on_begin(node)
          check(node)
        end

        def on_kwbegin(node)
          check(node)
        end

        private

        def check(node)
          children_to_check = node.children.reject do |child|
            # Don't check nodes that have special indentation and will be
            # checked by the AccessModifierIndentation cop.
            modifier_node?(child)
          end

          check_alignment(children_to_check)
        end
      end
    end
  end
end
