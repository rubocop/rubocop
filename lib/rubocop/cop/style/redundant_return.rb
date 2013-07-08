# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for redundant `return` expressions.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      # def test
      #   return something
      # end
      #
      # def test
      #   one
      #   two
      #   three
      #   return something
      # end
      #
      # It should be extended to handle methods whose body is if/else
      # or a case expression with a default branch.
      class RedundantReturn < Cop
        MSG = 'Redundant `return` detected.'

        def on_begin(node)

          super
        end

        def on_def(node)
          _method_name, _args, body = *node

          check(body)

          super
        end

        def on_defs(node)
          _scope, _method_name, _args, body = *node

          check(body)

          super
        end

        private

        def check(node)
          return unless node

          if node.type == :return
            add_offence(:convention, node.loc.keyword, MSG)
          elsif node.type == :begin
            expressions = *node
            last_expr = expressions.last

            if last_expr && last_expr.type == :return
              add_offence(:convention, last_expr.loc.keyword, MSG)
            end
          end
        end
      end
    end
  end
end
