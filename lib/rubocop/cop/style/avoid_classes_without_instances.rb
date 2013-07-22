# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for classes with singleton methods but no instance
      # methods. Classes that are not meant to be instantiated should not be
      # classes. They should be modules.
      class AvoidClassesWithoutInstances < Cop
        MSG = 'Prefer modules to classes with only class methods.'

        def on_class(node)
          class_node, base_class_node, members_node = *node
          if only_singleton_methods?(members_node) && !base_class_node
            add_offence(:convention, class_node.loc.expression, MSG)
          end
        end

        private

        def only_singleton_methods?(members_node)
          members = if members_node.nil?
                      []
                    elsif members_node.type == :begin
                      members_node.children
                    else
                      [members_node]
                    end
          members.find { |m| m.type == :defs } &&
            !members.find { |m| m.type == :def }
        end
      end
    end
  end
end
