# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for non-nil checks, which are usually redundant.
      #
      # @example
      #
      #  # bad
      #  if x != nil
      #  if !x.nil?
      #
      #  # good
      #  if x
      class NonNilCheck < Cop
        MSG = 'Explicit non-nil checks are usually redundant.'

        NIL_NODE = s(:nil)

        def on_send(node)
          receiver, method, args = *node

          return unless [:!=, :!].include?(method)

          if method == :!=
            add_offense(node, :selector) if args == NIL_NODE
          elsif method == :!
            add_offense(node, :expression) if nil_check?(receiver)
          end
        end

        private

        def nil_check?(node)
          return false unless node && node.type == :send

          _receiver, method, *_args = *node
          method == :nil?
        end

        def autocorrect(node)
          receiver, method, _args = *node

          if method == :!=
            autocorrect_comparison(node)
          elsif method == :!
            autocorrect_non_nil(node, receiver)
          end
        end

        def autocorrect_comparison(node)
          @corrections << lambda do |corrector|
            expr = node.loc.expression
            new_code = expr.source.sub(/\s*!=\s*nil/, '')
            corrector.replace(expr, new_code)
          end
        end

        def autocorrect_non_nil(node, inner_node)
          @corrections << lambda do |corrector|
            receiver, _method, _args = *inner_node
            corrector.replace(node.loc.expression,
                              receiver.loc.expression.source)
          end
        end
      end
    end
  end
end
