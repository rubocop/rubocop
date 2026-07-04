# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for trailing commas in attribute declarations, such as
      # `#attr_reader`. Leaving a trailing comma will nullify the next method
      # definition by overriding it with a getter method.
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     attr_reader :foo,
      #
      #     def bar
      #       puts "Unreachable."
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     attr_reader :foo
      #
      #     def bar
      #       puts "No problem!"
      #     end
      #   end
      #
      class TrailingCommaInAttributeDeclaration < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Avoid leaving a trailing comma in attribute declarations.'
        RESTRICT_ON_SEND = %i[attr_reader attr_writer attr_accessor attr].freeze

        def on_send(node)
          return unless node.attribute_accessor? && node.last_argument.any_def_type?
          # A lone `def` argument (e.g. `attr_reader def foo; end`) has no preceding
          # attribute, so there is no trailing comma to flag.
          return unless node.arguments.size > 1

          trailing_comma = trailing_comma_range(node)

          add_offense(trailing_comma) { |corrector| corrector.remove(trailing_comma) }
        end

        private

        def trailing_comma_range(node)
          range_with_surrounding_space(
            node.arguments[-2].source_range,
            side: :right
          ).end.resize(1)
        end
      end
    end
  end
end
