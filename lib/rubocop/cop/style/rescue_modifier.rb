# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of rescue in its modifier form.
      #
      # The cop to check `rescue` in its modifier form is added for following
      # reasons:
      #
      # * The syntax of modifier form `rescue` can be misleading because it
      #   might led us to believe that `rescue` handles the given exception
      #   but it actually rescue all exceptions to return the given rescue
      #   block. In this case, value returned by handle_error or
      #   SomeException.
      #
      # * Modifier form `rescue` would rescue all the exceptions. It would
      #   silently skip all exception or errors and handle the error.
      #   Example: If `NoMethodError` is raised, modifier form rescue would
      #   handle the exception.
      #
      # @example
      #   # bad
      #   some_method rescue handle_error
      #
      #   # bad
      #   some_method rescue SomeException
      #
      #   # good
      #   begin
      #     some_method
      #   rescue
      #     handle_error
      #   end
      #
      #   # good
      #   begin
      #     some_method
      #   rescue SomeException
      #     handle_error
      #   end
      class RescueModifier < Base
        include Alignment
        include RangeHelp
        include RescueNode
        extend AutoCorrector

        MSG = 'Avoid using `rescue` in its modifier form.'

        def self.autocorrect_incompatible_with
          [Style::MethodCallWithArgsParentheses]
        end

        def on_resbody(node)
          return unless rescue_modifier?(node)

          rescue_node = node.parent
          add_offense(rescue_node) do |corrector|
            parenthesized = parenthesized?(rescue_node)

            correct_rescue_block(corrector, rescue_node, parenthesized)
            ParenthesesCorrector.correct(corrector, rescue_node.parent) if parenthesized
          end
        end

        private

        def parenthesized?(node)
          node.parent && parentheses?(node.parent)
        end

        def correct_rescue_block(corrector, node, parenthesized)
          operation, rescue_modifier, = *node
          *_, rescue_args = *rescue_modifier

          node_indentation, node_offset = indentation_and_offset(node, parenthesized)

          corrector.remove(range_between(operation.source_range.end_pos, node.source_range.end_pos))
          corrector.insert_before(operation, "begin\n#{node_indentation}")
          corrector.insert_after(operation, <<~RESCUE_CLAUSE.chop)

            #{node_offset}rescue
            #{node_indentation}#{rescue_args.source}
            #{node_offset}end
          RESCUE_CLAUSE
        end

        def indentation_and_offset(node, parenthesized)
          node_indentation = indentation(node)
          node_offset = offset(node)
          if parenthesized
            node_indentation = node_indentation[0...-1]
            node_offset = node_offset[0...-1]
          end
          [node_indentation, node_offset]
        end
      end
    end
  end
end
