# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for non-nil checks, which are usually redundant.
      #
      # @example
      #
      #  # bad
      #  if x != nil
      #
      #  # good (when not allowing semantic changes)
      #  # bad (when allowing semantic changes)
      #  if !x.nil?
      #
      #  # good (when allowing semantic changes)
      #  if x
      #
      # Non-nil checks are allowed if they are the final nodes of predicate.
      #
      #  # good
      #  def signed_in?
      #    !current_user.nil?
      #  end
      class NonNilCheck < Cop
        include OnMethodDef

        def_node_matcher :not_equal_to_nil?, '(send _ :!= (:nil))'
        def_node_matcher :unless_check?, '(if (send _ :nil?) ...)'
        def_node_matcher :nil_check?, '(send _ :nil?)'
        def_node_matcher :not_and_nil_check?, '(send (send _ :nil?) :!)'

        def on_send(node)
          return if ignored_node?(node)

          if not_equal_to_nil?(node)
            add_offense(node, :selector)
          elsif include_semantic_changes? &&
                (not_and_nil_check?(node) || unless_and_nil_check?(node))
            add_offense(node, :expression)
          end
        end

        private

        def unless_and_nil_check?(send_node)
          parent = send_node.parent

          nil_check?(send_node) && unless_check?(parent) && !parent.ternary? &&
            parent.unless?
        end

        def message(node)
          if node.method?(:!=)
            'Prefer `!expression.nil?` over `expression != nil`.'
          else
            'Explicit non-nil checks are usually redundant.'
          end
        end

        def include_semantic_changes?
          cop_config['IncludeSemanticChanges']
        end

        def on_method_def(_node, name, _args, body)
          # only predicate methods are handled differently
          return unless name.to_s.end_with?('?') && body

          if body.begin_type?
            ignore_node(body.children.last)
          else
            ignore_node(body)
          end
        end

        def autocorrect(node)
          case node.method_name
          when :!=
            autocorrect_comparison(node)
          when :!
            autocorrect_non_nil(node, node.receiver)
          when :nil?
            autocorrect_unless_nil(node, node.receiver)
          end
        end

        def autocorrect_comparison(node)
          expr = node.source

          new_code = if include_semantic_changes?
                       expr.sub(/\s*!=\s*nil/, '')
                     else
                       expr.sub(/^(\S*)\s*!=\s*nil/, '!\1.nil?')
                     end

          return if expr == new_code

          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end

        def autocorrect_non_nil(node, inner_node)
          lambda do |corrector|
            if inner_node.receiver
              corrector.replace(node.source_range, inner_node.receiver.source)
            else
              corrector.replace(node.source_range, 'self')
            end
          end
        end

        def autocorrect_unless_nil(node, receiver)
          lambda do |corrector|
            corrector.replace(node.parent.loc.keyword, 'if')
            corrector.replace(node.source_range, receiver.source)
          end
        end
      end
    end
  end
end
