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
        include ConfigurableEnforcedStyle

        MSG = 'Inconsistent indentation detected.'.freeze

        def on_begin(node)
          check(node)
        end

        def on_kwbegin(node)
          check(node)
        end

        private

        def check(node)
          children_to_check = [[]]
          node.children.each do |child|
            # Modifier nodes have special indentation and will be checked by
            # the AccessModifierIndentation cop. This cop uses them as dividers
            # in rails mode. Then consistency is checked only within each
            # section delimited by a modifier node.
            if modifier_node?(child)
              children_to_check << [] if style == :rails
            else
              children_to_check.last << child
            end
          end
          children_to_check.each { |group| check_alignment(group) }
        end
      end
    end
  end
end
