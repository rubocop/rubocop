# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Access modifiers should be declared to apply to a group of methods
      # or inline before each method, depending on configuration.
      # EnforcedStyle config covers only method definitions.
      # Applications of visibility methods to symbols can be controlled
      # using AllowModifiersOnSymbols config.
      #
      # @example EnforcedStyle: group (default)
      #   # bad
      #   class Foo
      #
      #     private def bar; end
      #     private def baz; end
      #
      #   end
      #
      #   # good
      #   class Foo
      #
      #     private
      #
      #     def bar; end
      #     def baz; end
      #
      #   end
      #
      # @example EnforcedStyle: inline
      #   # bad
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
      #   class Foo
      #
      #     private def bar; end
      #     private def baz; end
      #
      #   end
      #
      # @example AllowModifiersOnSymbols: true
      #   # good
      #   class Foo
      #
      #     private :bar, :baz
      #
      #   end
      #
      # @example AllowModifiersOnSymbols: false
      #   # bad
      #   class Foo
      #
      #     private :bar, :baz
      #
      #   end
      class AccessModifierDeclarations < Base
        include ConfigurableEnforcedStyle

        GROUP_STYLE_MESSAGE = [
          '`%<access_modifier>s` should not be',
          'inlined in method definitions.'
        ].join(' ')

        INLINE_STYLE_MESSAGE = [
          '`%<access_modifier>s` should be',
          'inlined in method definitions.'
        ].join(' ')

        RESTRICT_ON_SEND = %i[private protected public module_function].freeze

        def_node_matcher :access_modifier_with_symbol?, <<~PATTERN
          (send nil? {:private :protected :public} (sym _))
        PATTERN

        def on_send(node)
          return unless node.access_modifier?
          return if node.parent&.pair_type?
          return if allow_modifiers_on_symbols?(node)

          if offense?(node)
            add_offense(node.loc.selector) if opposite_style_detected
          else
            correct_style_detected
          end
        end

        private

        def allow_modifiers_on_symbols?(node)
          cop_config['AllowModifiersOnSymbols'] && access_modifier_with_symbol?(node)
        end

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

        def message(range)
          access_modifier = range.source

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
