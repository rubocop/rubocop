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
      #   when baz
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

        def comment_lines
          @comment_lines ||= processed_source.comments.map{|comment| comment.loc.line}
        end

        private

        def check_when(when_node)
          return unless empty_when_body?(when_node)
          add_offense(when_node, when_node.source_range, MSG)
        end

        def empty_when_body?(when_node)
          !when_node.to_a.last && no_comments?(when_node)
        end

        def no_comments?(when_node)
          (comment_lines & line_range_to_next_node(when_node)).empty?
        end

        def line_range_to_next_node(node)
          current_node_begin_line = node.loc.expression.begin.line
          next_node_begin_line = if next_node(node)
                                    next_node(node).loc.expression.begin.line
                                 else
                                    processed_source.lines.length
                                 end
          (current_node_begin_line..next_node_begin_line).to_a
        end

        def next_node(node)
          return nil unless node.sibling_index > 0
          node.parent.children[node.sibling_index + 1]
        end
      end
    end
  end
end
