# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks for methods with too many parameters.
      #
      # The maximum number of parameters is configurable.
      # Keyword arguments can optionally be excluded from the total count,
      # as they add less complexity than positional or optional parameters.
      #
      # @example Max: 3
      #   # good
      #   def foo(a, b, c = 1)
      #   end
      #
      # @example Max: 2
      #   # bad
      #   def foo(a, b, c = 1)
      #   end
      #
      # @example CountKeywordArgs: true (default)
      #   # counts keyword args towards the maximum
      #
      #   # bad (assuming Max is 3)
      #   def foo(a, b, c, d: 1)
      #   end
      #
      #   # good (assuming Max is 3)
      #   def foo(a, b, c: 1)
      #   end
      #
      # @example CountKeywordArgs: false
      #   # don't count keyword args towards the maximum
      #
      #   # good (assuming Max is 3)
      #   def foo(a, b, c, d: 1)
      #   end
      class ParameterLists < Base
        include ConfigurableMax

        MSG = 'Avoid parameter lists longer than %<max>d parameters. ' \
              '[%<count>d/%<max>d]'

        NAMED_KEYWORD_TYPES = %i[kwoptarg kwarg].freeze
        private_constant :NAMED_KEYWORD_TYPES

        def on_args(node)
          count = args_count(node)
          return unless count > max_params

          return if argument_to_lambda_or_proc?(node)

          add_offense(node, message: format(MSG, max: max_params, count: args_count(node))) do
            self.max = count
          end
        end

        private

        def_node_matcher :argument_to_lambda_or_proc?, <<~PATTERN
          ^lambda_or_proc?
        PATTERN

        def args_count(node)
          if count_keyword_args?
            node.children.size
          else
            node.children.count { |a| !NAMED_KEYWORD_TYPES.include?(a.type) }
          end
        end

        def max_params
          cop_config['Max']
        end

        def count_keyword_args?
          cop_config['CountKeywordArgs']
        end
      end
    end
  end
end
