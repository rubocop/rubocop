# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      MSG = 'Avoid rescuing the Exception class.'

      def self.portable?
        true
      end

      def inspect(file, source, node)
        on_node(:resbody, node) do |n|
          next unless n.children.first
          rescue_args = n.children.first.children
          if rescue_args.any? { |a| targets_exception?(a) }
            add_offence(:warning,
                        n.source_map.line,
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
