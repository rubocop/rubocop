# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that all methods and variables use
      # snake_case for their names. Some special arrangements have to be
      # made for operator methods.
      class MethodAndVariableSnakeCase < Cop
        MSG = 'Use snake_case for methods and variables.'
        SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/

        def investigate(processed_source)
          ast = processed_source.ast
          return unless ast
          on_node([:def, :defs, :lvasgn, :ivasgn, :send], ast) do |n|
            name = case n.type
                   when :def
                     name_of_instance_method(n)
                   when :defs
                     name_of_singleton_method(n)
                   when :lvasgn, :ivasgn
                     name_of_variable(n)
                   when :send
                     name_of_setter(n)
                   end

            next unless name
            next if name =~ SNAKE_CASE || OPERATOR_METHODS.include?(name)

            add_offence(:convention, n.location.expression, MSG)
          end
        end

        def name_of_instance_method(def_node)
          def_node.children.first
        end

        def name_of_singleton_method(defs_node)
          defs_node.children[1]
        end

        def name_of_variable(vasgn_node)
          vasgn_node.children.first
        end

        def name_of_setter(send_node)
          receiver, method_name = *send_node
          return nil unless receiver && receiver.type == :self
          return nil unless method_name.to_s.end_with?('=')
          method_name
        end
      end
    end
  end
end
