# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks unexpected overrides of the `Struct` original methods
      # via `Struct.new`.
      #
      # @example
      #   # bad
      #   Bad = Struct.new(:members, :clone, :count)
      #   b = Bad.new([], true, 1)
      #   b.members #=> [] (overriding `Struct#members`)
      #   b.clone #=> true (overriding `Object#clone`)
      #   b.count #=> 1 (overriding `Enumerable#count`)
      #
      #   # good
      #   Good = Struct.new(:id, :name)
      #   g = Good.new(1, "foo")
      #   g.members #=> [:id, :name]
      #   g.clone #=> #<struct Good id=1, name="foo">
      #   g.count #=> 2
      #
      class StructNewOverride < Cop
        MSG = 'Disallow overriding the `Struct#%<method_name>s` method.'

        STRUCT_METHOD_NAMES = Struct.instance_methods

        def_node_matcher :struct_new, <<~PATTERN
          (send
            (const ${nil? cbase} :Struct) :new ...)
        PATTERN

        def on_send(node)
          return unless struct_new(node) do
            node.arguments.each do |arg|
              next unless arg.respond_to?(:value)

              method_name = arg.value

              next unless STRUCT_METHOD_NAMES.include?(method_name)

              add_offense(arg, message: format(MSG, method_name: method_name))
            end
          end
        end
      end
    end
  end
end
