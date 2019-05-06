# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant `return` expressions.
      #
      # @example
      #   # These bad cases should be extended to handle methods whose body is
      #   # if/else or a case expression with a default branch.
      #
      #   # bad
      #   def test
      #     return something
      #   end
      #
      #   # bad
      #   def test
      #     one
      #     two
      #     three
      #     return something
      #   end
      #
      #   # good
      #   def test
      #     return something if something_else
      #   end
      #
      #   # good
      #   def test
      #     if x
      #     elsif y
      #     else
      #     end
      #   end
      #
      class RedundantReturn < Cop
        include RangeHelp

        MSG = 'Redundant `return` detected.'
        MULTI_RETURN_MSG = 'To return multiple values, use an array.'

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

        # rubocop:disable Metrics/CyclomaticComplexity
        def check_branch(node)
          return unless node

          case node.type
          when :return then check_return_node(node)
          when :case   then check_case_node(node)
          when :if     then check_if_node(node)
          when :rescue, :resbody
            check_rescue_node(node)
          when :ensure then check_ensure_node(node)
          when :begin, :kwbegin
            check_begin_node(node)
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def check_return_node(node)
          return if cop_config['AllowMultipleReturnValues'] &&
                    node.children.size > 1

          add_offense(node, location: :keyword)
        end

        def check_case_node(node)
          node.when_branches.each { |when_node| check_branch(when_node.body) }
          check_branch(node.else_branch)
        end

        def check_if_node(node)
          return if node.modifier_form? || node.ternary?

          check_branch(node.if_branch)
          check_branch(node.else_branch)
        end

        def check_rescue_node(node)
          node.child_nodes.each do |child_node|
            check_branch(child_node)
          end
        end

        def check_ensure_node(node)
          rescue_node = node.node_parts[0]
          check_branch(rescue_node)
        end

        def check_begin_node(node)
          expressions = *node
          last_expr = expressions.last

          return unless last_expr&.return_type?

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
