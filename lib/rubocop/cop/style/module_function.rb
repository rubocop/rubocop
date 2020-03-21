# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for use of `extend self` or `module_function` in a
      # module.
      #
      # Supported styles are: module_function, extend_self, forbidden.
      #
      # @example EnforcedStyle: module_function (default)
      #   # bad
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      #   # good
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      # In case there are private methods, the cop won't be activated.
      # Otherwise, it forces to change the flow of the default code.
      #
      # @example EnforcedStyle: module_function (default)
      #   # good
      #   module Test
      #     extend self
      #     # ...
      #     private
      #     # ...
      #   end
      #
      # @example EnforcedStyle: extend_self
      #   # bad
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      #   # good
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      # The option `forbidden` prohibits the usage of both styles.
      #
      # @example EnforcedStyle: forbidden
      #   # bad
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      #   # bad
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      #   # bad
      #   module Test
      #     extend self
      #     # ...
      #     private
      #     # ...
      #   end
      #
      # These offenses are not safe to auto-correct since there are different
      # implications to each approach.
      class ModuleFunction < Cop
        include ConfigurableEnforcedStyle

        MODULE_FUNCTION_MSG =
          'Use `module_function` instead of `extend self`.'
        EXTEND_SELF_MSG =
          'Use `extend self` instead of `module_function`.'
        FORBIDDEN_MSG =
          'Do not use `module_function` or `extend self`.'

        def_node_matcher :module_function_node?, '(send nil? :module_function)'
        def_node_matcher :extend_self_node?, '(send nil? :extend self)'
        def_node_matcher :private_directive?, '(send nil? :private ...)'

        def on_module(node)
          return unless node.body&.begin_type?

          each_wrong_style(node.body.children) do |child_node|
            add_offense(child_node)
          end
        end

        def autocorrect(node)
          return if style == :forbidden

          lambda do |corrector|
            if extend_self_node?(node)
              corrector.replace(node.source_range, 'module_function')
            else
              corrector.replace(node.source_range, 'extend self')
            end
          end
        end

        private

        def each_wrong_style(nodes, &block)
          case style
          when :module_function
            check_module_function(nodes, &block)
          when :extend_self
            check_extend_self(nodes, &block)
          when :forbidden
            check_forbidden(nodes, &block)
          end
        end

        def check_module_function(nodes)
          private_directive = nodes.any? { |node| private_directive?(node) }

          nodes.each do |node|
            yield node if extend_self_node?(node) && !private_directive
          end
        end

        def check_extend_self(nodes)
          nodes.each do |node|
            yield node if module_function_node?(node)
          end
        end

        def check_forbidden(nodes)
          nodes.each do |node|
            yield node if extend_self_node?(node)
            yield node if module_function_node?(node)
          end
        end

        def message(_node)
          return FORBIDDEN_MSG if style == :forbidden

          style == :module_function ? MODULE_FUNCTION_MSG : EXTEND_SELF_MSG
        end
      end
    end
  end
end
