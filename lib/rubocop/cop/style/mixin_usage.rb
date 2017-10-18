# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that `include`, `extend` and `prepend` exists at
      # the top level.
      # Using these at the top level affects the behavior of `Object`.
      # There will not be using `include`, `extend` and `prepend` at
      # the top level. Let's use it inside `class` or `module`.
      #
      # @example
      #   # bad
      #   include M
      #
      #   class C
      #   end
      #
      #   # bad
      #   extend M
      #
      #   class C
      #   end
      #
      #   # bad
      #   prepend M
      #
      #   class C
      #   end
      #
      #   # good
      #   class C
      #     include M
      #   end
      #
      #   # good
      #   class C
      #     extend M
      #   end
      #
      #   # good
      #   class C
      #     prepend M
      #   end
      class MixinUsage < Cop
        MSG = '`%<statement>s` is used at the top level. Use inside `class` ' \
              'or `module`.'.freeze

        def_node_matcher :include_statement, <<-PATTERN
          (send nil? ${:include :extend :prepend}
            (const nil? _))
        PATTERN

        def on_send(node)
          return unless (statement = include_statement(node))
          return unless top_level_node?(node)

          add_offense(node, message: format(MSG, statement: statement))
        end

        private

        def top_level_node?(node)
          if node.parent.parent.nil?
            node.sibling_index.zero?
          else
            top_level_node?(node.parent)
          end
        end
      end
    end
  end
end
