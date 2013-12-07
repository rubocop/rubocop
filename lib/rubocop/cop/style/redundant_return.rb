# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for redundant `return` expressions.
      #
      # @example
      #
      #   def test
      #     return something
      #   end
      #
      #   def test
      #     one
      #     two
      #     three
      #     return something
      #   end
      #
      # It should be extended to handle methods whose body is if/else
      # or a case expression with a default branch.
      class RedundantReturn < Cop
        include CheckMethods

        MSG = 'Redundant `return` detected.'

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if node.children.size > 1
              kids = node.children.map { |child| child.loc.expression }
              corrector.insert_before(kids.first, '[')
              corrector.insert_after(kids.last, ']')
            end
            return_kw = range_with_surrounding_space(node.loc.keyword, :right)
            corrector.remove(return_kw)
          end
        end

        def check(_node, _method_name, _args, body)
          return unless body

          if body.type == :return
            check_return_node(body)
          elsif body.type == :begin
            expressions = *body
            last_expr = expressions.last

            if last_expr && last_expr.type == :return
              check_return_node(last_expr)
            end
          end
        end

        def check_return_node(node)
          return if cop_config['AllowMultipleReturnValues'] &&
            node.children.size > 1

          add_offence(node, :keyword)
        end
      end
    end
  end
end
