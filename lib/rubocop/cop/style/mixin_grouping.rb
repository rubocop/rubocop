# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for grouping of mixins in `class` and `module` bodies.
      # By default it enforces mixins to be placed in separate declarations,
      # but it can be configured to enforce grouping them in one declaration.
      #
      # @example
      #
      #   EnforcedStyle: separated (default)
      #
      #   @bad
      #   class Foo
      #     include Bar, Qox
      #   end
      #
      #   @good
      #   class Foo
      #     include Qox
      #     include Bar
      #   end
      #
      #   EnforcedStyle: grouped
      #
      #   @bad
      #   class Foo
      #     extend Bar
      #     extend Qox
      #   end
      #
      #   @good
      #   class Foo
      #     extend Qox, Bar
      #   end
      class MixinGrouping < Cop
        include ConfigurableEnforcedStyle

        MIXIN_METHODS = %i[extend include prepend].freeze
        MSG = 'Put `%s` mixins in %s.'.freeze

        def on_send(node)
          return unless node.macro? && MIXIN_METHODS.include?(node.method_name)

          check(node)
        end

        private

        def check(send_node)
          if separated_style?
            check_separated_style(send_node)
          else
            check_grouped_style(send_node)
          end
        end

        def check_grouped_style(send_node)
          return unless sibling_mixins?(send_node)

          add_offense(send_node, :expression)
        end

        def check_separated_style(send_node)
          return if send_node.arguments.one?

          add_offense(send_node, :expression)
        end

        def sibling_mixins?(send_node)
          siblings = send_node.parent.each_child_node(:send)
                              .reject { |sibling| sibling == send_node }

          siblings.any? do |sibling_node|
            sibling_node.method_name == send_node.method_name
          end
        end

        def message(send_node)
          suffix =
            separated_style? ? 'separate statements' : 'a single statement'

          format(MSG, send_node.method_name, suffix)
        end

        def grouped_style?
          style == :grouped
        end

        def separated_style?
          style == :separated
        end
      end
    end
  end
end
