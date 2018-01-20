# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for use of `extend self` or `module_function` in a
      # module.
      #
      # Supported styles are: module_function, extend_self.
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
      # These offenses are not auto-corrected since there are different
      # implications to each approach.
      class ModuleFunction < Cop
        include ConfigurableEnforcedStyle

        MODULE_FUNCTION_MSG =
          'Use `module_function` instead of `extend self`.'.freeze
        EXTEND_SELF_MSG =
          'Use `extend self` instead of `module_function`.'.freeze

        def_node_matcher :module_function_node?, '(send nil? :module_function)'
        def_node_matcher :extend_self_node?, '(send nil? :extend self)'

        def on_module(node)
          _name, body = *node
          return unless body && body.begin_type?

          each_wrong_style(body.children) do |child_node|
            add_offense(child_node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if extend_self_node?(node)
              corrector.replace(node.source_range, 'module_function')
            else
              corrector.replace(node.source_range, 'extend self')
            end
          end
        end

        private

        def each_wrong_style(nodes)
          case style
          when :module_function
            nodes.each do |node|
              yield node if extend_self_node?(node)
            end
          when :extend_self
            nodes.each do |node|
              yield node if module_function_node?(node)
            end
          end
        end

        def message(_node)
          style == :module_function ? MODULE_FUNCTION_MSG : EXTEND_SELF_MSG
        end
      end
    end
  end
end
