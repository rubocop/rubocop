# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks for methods with too many parameters.
      # The maximum number of parameters is configurable.
      # On Ruby 2.0+ keyword arguments can optionally
      # be excluded from the total count.
      class ParameterLists < Cop
        include ConfigurableMax

        MSG = 'Avoid parameter lists longer than %d parameters.'.freeze

        def on_args(node)
          count = args_count(node)
          return unless count > max_params

          add_offense(node, :expression, format(MSG, max_params)) do
            self.max = count
          end
        end

        private

        def args_count(node)
          if count_keyword_args?
            node.children.size
          else
            node.children.count { |a| ![:kwoptarg, :kwarg].include?(a.type) }
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
