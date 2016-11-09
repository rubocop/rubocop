# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the presence of `when` branches without a body.
      #
      # @example
      #
      #   @bad
      #   case foo
      #   when bar then 1
      #   when baz then # nothing
      #   end
      class EmptyWhen < Cop
        MSG = 'Avoid `when` branches without a body.'.freeze

        def investigate(processed_source)
          @processed_source = processed_source
        end

        def on_case(node)
          _cond_node, *when_nodes, _else_node = *node

          when_nodes.each do |when_node|
            check_when(when_node)
          end
        end

        private

        def check_when(when_node)
          return unless empty_when_body?(when_node)
          add_offense(when_node, when_node.source_range, MSG)
        end

        def empty_when_body?(when_node)
          node_comment = @processed_source[when_node.loc.first_line]
          !(when_node.to_a.last || comment_line?(node_comment))
        end
      end
    end
  end
end
