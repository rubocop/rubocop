# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      MSG = 'Avoid rescuing the Exception class.'

      def inspect(file, source, tokens, node)
        on_node(:resbody, node) do |n|
          next unless n.children.first
          rescue_args = n.children.first.children
          if rescue_args.any? { |a| targets_exception?(a) }
            add_offence(:warning,
                        n.location.line,
                        MSG)
          end
        end
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
