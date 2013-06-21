# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for methods with too many parameters.
      # The maximum number of parameters in configurable.
      # On Ruby 2.0+ keyword arguments can optionally
      # be excluded from the total count.
      class ParameterLists < Cop
        MSG = 'Avoid parameter lists longer than %d parameters.'

        def on_args(node)
          if args_count(node) > max_params
            add_offence(:convention, node.loc.expression,
                        sprintf(MSG, max_params))
          end

          super
        end

        private

        def args_count(node)
          if count_keyword_args?
            node.children.size
          else
            node.children.reject { |a| a.type == :kwoptarg }.size
          end
        end

        def max_params
          ParameterLists.config['Max']
        end

        def count_keyword_args?
          ParameterLists.config['CountKeywordArgs']
        end
      end
    end
  end
end
