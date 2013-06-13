# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      MSG = 'Avoid rescuing the Exception class.'

      def on_resbody(node)
        return unless node.children.first
        rescue_args = node.children.first.children
        if rescue_args.any? { |a| targets_exception?(a) }
          add_offence(:warning, node.location.expression, MSG)
        end

        super
      end

      def targets_exception?(rescue_arg_node)
        return false unless rescue_arg_node.type == :const
        namespace, klass_name = *rescue_arg_node
        return false unless namespace.nil? || namespace.type == :cbase
        klass_name == :Exception
      end
    end
  end
end
