# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for ambiguous block association with method
      # when param passed without parentheses.
      #
      # This cop also detects `do...end` blocks that are likely intended for
      # an enumerable method in the arguments but actually bind to the outer
      # method call. For example, in `render json: data.map do |x| x end`,
      # Ruby parses the `do...end` block as belonging to `render`, not `map`.
      #
      # This cop can customize allowed methods with `AllowedMethods`.
      # By default, there are no methods to allowed.
      #
      # @example
      #
      #   # bad
      #   some_method a { |val| puts val }
      #
      #   # good
      #   # With parentheses, there's no ambiguity.
      #   some_method(a { |val| puts val })
      #   # or (different meaning)
      #   some_method(a) { |val| puts val }
      #
      #   # bad
      #   render json: data.map do |item|
      #     item.to_h
      #   end
      #
      #   # good
      #   render json: data.map { |item| item.to_h }
      #
      #   # good
      #   mapped = data.map { |item| item.to_h }
      #   render json: mapped
      #
      #   # good
      #   # Operator methods require no disambiguation
      #   foo == bar { |b| b.baz }
      #
      #   # good
      #   # Lambda arguments require no disambiguation
      #   foo = ->(bar) { bar.baz }
      #
      # @example AllowedMethods: [] (default)
      #
      #   # bad
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedMethods: [change]
      #
      #   # good
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedPatterns: [] (default)
      #
      #   # bad
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedPatterns: ['change']
      #
      #   # good
      #   expect { do_something }.to change { object.attribute }
      #   expect { do_something }.to not_change { object.attribute }
      #
      class AmbiguousBlockAssociation < Base
        extend AutoCorrector

        include AllowedMethods
        include AllowedPattern

        MSG = 'Parenthesize the param `%<param>s` to make sure that the ' \
              'block will be associated with the `%<method>s` method ' \
              'call.'
        MSG_DO_END_BLOCK = '`%<inner_method>s` is called without a block because the ' \
                           '`do` block binds to `%<outer_method>s`. ' \
                           'Use braces or extract to a variable.'

        BLOCK_METHODS = %i[
          map collect flat_map collect_concat
          select filter find_all reject
          find detect
          each each_with_object each_with_index
          reduce inject
          sort_by min_by max_by
          group_by filter_map
        ].to_set.freeze

        def on_send(node)
          return unless node.arguments?

          return unless ambiguous_block_association?(node)
          return if node.parenthesized? || node.last_argument.lambda_or_proc? ||
                    allowed_method_pattern?(node)

          message = message(node)

          add_offense(node, message: message) do |corrector|
            wrap_in_parentheses(corrector, node)
          end
        end
        alias on_csend on_send

        def on_block(node)
          return if node.braces?

          send_node = node.send_node
          block_method_arg = find_ambiguous_block_method(node)
          return unless block_method_arg

          add_offense(block_method_arg,
                      message: format(MSG_DO_END_BLOCK,
                                      inner_method: block_method_arg.method_name,
                                      outer_method: send_node.method_name))
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def find_ambiguous_block_method(block_node)
          send_node = block_node.send_node
          return unless send_node.send_type? && send_node.arguments?
          return if send_node.parenthesized?

          block_method_arg = find_block_method_arg(send_node)
          return unless block_method_arg
          return if allowed_method?(block_method_arg.method_name) ||
                    matches_allowed_pattern?(block_method_arg.source)

          block_method_arg
        end

        def ambiguous_block_association?(send_node)
          send_node.last_argument.any_block_type? && !send_node.last_argument.send_node.arguments?
        end

        def allowed_method_pattern?(node)
          node.assignment? || node.operator_method? || node.method?(:[]) ||
            allowed_method?(node.last_argument.method_name) ||
            matches_allowed_pattern?(node.last_argument.send_node.source)
        end

        def message(send_node)
          block_param = send_node.last_argument

          format(MSG, param: block_param.source, method: block_param.send_node.source)
        end

        def find_block_method_arg(send_node)
          send_node.arguments.each do |arg|
            arg.each_node(:call) do |node|
              next if node.parent&.any_block_type?

              return node if BLOCK_METHODS.include?(node.method_name) && !node.arguments?
            end
          end
          nil
        end

        def wrap_in_parentheses(corrector, node)
          range = node.loc.selector.end.join(node.first_argument.source_range.begin)

          corrector.remove(range)
          corrector.insert_before(range, '(')
          corrector.insert_after(node.last_argument, ')')
        end
      end
    end
  end
end
