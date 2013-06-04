# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      MSG = 'Avoid parameter lists longer than %d parameters.'

      def on_args(node)
        args_count = node.children.size

        if args_count > max_params
          add_offence(:convention, node.loc, sprintf(MSG, max_params))
        end

        super
      end

      def max_params
        ParameterLists.config['Max']
      end
    end
  end
end
