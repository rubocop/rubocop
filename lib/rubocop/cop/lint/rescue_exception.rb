# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks targeting the Exception class.
      class RescueException < Cop
        MSG = 'Avoid rescuing the Exception class.'

        def on_resbody(node)
          return unless node.children.first
          rescue_args = node.children.first.children
          if rescue_args.any? { |a| targets_exception?(a) }
            add_offence(node, :expression)
          end
        end

        def targets_exception?(rescue_arg_node)
          Util.const_name(rescue_arg_node) == 'Exception'
        end
      end
    end
  end
end
