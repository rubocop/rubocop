# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks for methods with too many parameters.
      # The maximum number of parameters is configurable.
      # Keyword arguments can optionally be excluded from the total count.
      class ParameterLists < Cop
        include ConfigurableMax

        MSG = 'Avoid parameter lists longer than %d parameters. [%d/%d]'.freeze

        def on_args(node)
          count = args_count(node)
          return unless count > max_params

          add_offense(node) do
            self.max = count
          end
        end

        private

        def message(node)
          format(MSG, max_params, args_count(node), max_params)
        end

        def args_count(node)
          if count_keyword_args?
            node.children.size
          else
            node.children.count { |a| !%i[kwoptarg kwarg].include?(a.type) }
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
