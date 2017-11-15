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
            const)
        PATTERN

        def on_send(node)
          include_statement(node) do |statement|
            return if node.argument?
            return if accepted_include?(node)

            add_offense(node, message: format(MSG, statement: statement))
          end
        end

        private

        def accepted_include?(node)
          node.parent && node.macro?
        end
      end
    end
  end
end
