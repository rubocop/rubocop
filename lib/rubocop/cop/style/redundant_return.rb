# encoding: utf-8
# frozen_string_literal: true

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

        MSG = 'Redundant `return` detected.'.freeze

        private

        def autocorrect(node)
          lambda do |corrector|
            unless arguments?(node.children)
              corrector.replace(node.source_range, 'nil')
              next
            end

            return_value, = *node
            if node.children.size > 1
              add_brackets(corrector, node)
            elsif return_value.hash_type?
              add_braces(corrector, return_value) unless braces?(return_value)
            end
            return_kw = range_with_surrounding_space(node.loc.keyword, :right)
            corrector.remove(return_kw)
          end
        end

        def braces?(arg)
          arg.loc.begin
        end

        def add_brackets(corrector, node)
          kids = node.children.map(&:source_range)
          corrector.insert_before(kids.first, '[')
          corrector.insert_after(kids.last, ']')
        end

        def add_braces(corrector, node)
          kids = node.children.map(&:source_range)
          corrector.insert_before(kids.first, '{')
          corrector.insert_after(kids.last, '}')
        end

        def arguments?(args)
          return false if args.empty?
          return true if args.size > 1

          !args.first.begin_type? || !args.first.children.empty?
        end

        def on_method_def(_node, _method_name, _args, body)
          return unless body

          if body.return_type?
            check_return_node(body)
          elsif body.begin_type?
            expressions = *body
            last_expr = expressions.last

            return unless last_expr && last_expr.return_type?

            check_return_node(last_expr)
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
