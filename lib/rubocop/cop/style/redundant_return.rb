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
        include RangeHelp

        MSG = 'Redundant `return` detected.'.freeze
        MULTI_RETURN_MSG = 'To return multiple values, use an array.'.freeze

        def on_def(node)
          return unless node.body

          check_branch(node.body)
        end
        alias on_defs on_def

        def autocorrect(node) # rubocop:disable Metrics/MethodLength
          lambda do |corrector|
            unless arguments?(node.children)
              corrector.replace(node.source_range, 'nil')
              next
            end

            return_value, = *node
            if node.children.size > 1
              add_brackets(corrector, node)
            elsif return_value.hash_type?
              add_braces(corrector, return_value) unless return_value.braces?
            end
            return_kw = range_with_surrounding_space(range: node.loc.keyword,
                                                     side: :right)
            corrector.remove(return_kw)
          end
        end

        private

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

        def check_branch(node)
          case node.type
          when :return then check_return_node(node)
          when :case   then check_case_node(node)
          when :if     then check_if_node(node)
          when :begin  then check_begin_node(node)
          end
        end

        def check_return_node(node)
          return if cop_config['AllowMultipleReturnValues'] &&
                    node.children.size > 1

          add_offense(node, location: :keyword)
        end

        def check_case_node(node)
          _cond, *when_nodes, else_node = *node
          when_nodes.each { |when_node| check_when_node(when_node) }
          check_branch(else_node) if else_node
        end

        def check_when_node(node)
          return unless node
          _cond, body = *node
          check_branch(body) if body
        end

        def check_if_node(node)
          return if node.modifier_form? || node.ternary?

          _cond, if_node, else_node = *node.node_parts

          check_branch(if_node) if if_node
          check_branch(else_node) if else_node
        end

        def check_begin_node(node)
          expressions = *node
          last_expr = expressions.last

          return unless last_expr && last_expr.return_type?

          check_return_node(last_expr)
        end

        def allow_multiple_return_values?
          cop_config['AllowMultipleReturnValues'] || false
        end

        def message(node)
          if !allow_multiple_return_values? && node.children.size > 1
            "#{MSG} #{MULTI_RETURN_MSG}"
          else
            MSG
          end
        end
      end
    end
  end
end
