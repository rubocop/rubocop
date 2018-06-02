# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Access modifiers should be declared to apply to a group of methods
      # or inline before each method, depending on configuration.
      #
      # @example EnforcedStyle: group (default)
      #
      #   # bad
      #
      #   class Foo
      #
      #     private def bar; end
      #     private def baz; end
      #
      #   end
      #
      #   # good
      #
      #   class Foo
      #
      #     private
      #
      #     def bar; end
      #     def baz; end
      #
      #   end
      # @example EnforcedStyle: inline
      #
      #   # bad
      #
      #   class Foo
      #
      #     private
      #
      #     def bar; end
      #     def baz; end
      #
      #   end
      #
      #   # good
      #
      #   class Foo
      #
      #     private def bar; end
      #     private def baz; end
      #
      #   end
      class AccessModifierDeclarations < Cop
        include ConfigurableEnforcedStyle

        GROUP_STYLE_MESSAGE = [
          '`%<access_modifier>s` should not be',
          'inlined in method definitions.'
        ].join(' ')

        INLINE_STYLE_MESSAGE = [
          '`%<access_modifier>s` should be',
          'inlined in method definitions.'
        ].join(' ')

        def on_send(node)
          return unless node.access_modifier?

          if offense?(node)
            add_offense(node, location: :selector) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        private

        def offense?(node)
          (group_style? && access_modifier_is_inlined?(node)) ||
            (inline_style? && access_modifier_is_not_inlined?(node))
        end

        def group_style?
          style == :group
        end

        def inline_style?
          style == :inline
        end

        def access_modifier_is_inlined?(node)
          node.arguments.any?
        end

        def access_modifier_is_not_inlined?(node)
          !access_modifier_is_inlined?(node)
        end

        def message(node)
          access_modifier = node.loc.selector.source

          if group_style?
            format(GROUP_STYLE_MESSAGE, access_modifier: access_modifier)
          elsif inline_style?
            format(INLINE_STYLE_MESSAGE, access_modifier: access_modifier)
          end
        end
      end
    end
  end
end
