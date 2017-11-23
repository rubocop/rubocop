# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that `#module_function` is used over `extend self`.
      #
      # @example EnforcedStyle: module_function (default)
      #
      #   # bad
      #   module Foo
      #     extend self
      #   end
      #
      #   # good
      #   module Foo
      #     module_function
      #   end
      #
      # @example EnforcedStyle: extend_self
      #
      #   # bad
      #   module Foo
      #     module_function
      #   end
      #
      #   # good
      #   module Foo
      #     extend self
      #   end
      class ExtendSelf < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%<enforced>s` instead of `%<alternate>s`.'.freeze

        def_node_matcher :extend_self?, <<-PATTERN
          (send nil? :extend (self))
        PATTERN

        def_node_matcher :module_function?, <<-PATTERN
          (send nil? :module_function)
        PATTERN

        def_node_matcher :module_scope?, <<-PATTERN
          {^(module ...) ^^(module _ ({begin kwbegin} ...))}
        PATTERN

        def on_send(node)
          return unless module_scope?(node)
          return unless module_function_enforced? && extend_self?(node) ||
                        extend_self_enforced? && module_function?(node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, enforced_source)
          end
        end

        private

        def message(_node)
          format(MSG, enforced: enforced_source, alternate: alternate_source)
        end

        def enforced_source
          case style
          when :module_function then 'module_function'
          when :extend_self     then 'extend self'
          end
        end

        def alternate_source
          case style
          when :module_function then 'extend self'
          when :extend_self     then 'module_function'
          end
        end

        def module_function_enforced?
          style == :module_function
        end

        def extend_self_enforced?
          style == :extend_self
        end
      end
    end
  end
end
