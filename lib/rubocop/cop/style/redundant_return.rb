# encoding: utf-8

module RuboCop
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
        include OnMethodDef

        MSG = 'Redundant `return` detected.'

        private

        def autocorrect(node)
          lambda do |corrector|
            unless arguments?(node.children)
              corrector.replace(node.loc.expression, 'nil')
              next
            end

            if node.children.size > 1
              kids = node.children.map { |child| child.loc.expression }
              corrector.insert_before(kids.first, '[')
              corrector.insert_after(kids.last, ']')
            end
            return_kw = range_with_surrounding_space(node.loc.keyword, :right)
            corrector.remove(return_kw)
          end
        end

        def arguments?(args)
          return false if args.empty?
          return true if args.size > 1

          !args.first.begin_type? || !args.first.children.empty?
        end

        def on_method_def(_node, _method_name, _args, body)
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

          add_offense(node, :keyword)
        end
      end
    end
  end
end
