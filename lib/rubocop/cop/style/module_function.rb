# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for use of `extend self` or `module_function` in a
      # module.
      #
      # Supported styles are: module_function, extend_self.
      #
      # @example
      #
      #   # Good if EnforcedStyle is module_function
      #   module Test
      #     module_function
      #     ...
      #   end
      #
      #   # Good if EnforcedStyle is extend_self
      #   module Test
      #     extend self
      #     ...
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

        def_node_matcher :module_function_node?, '(send nil :module_function)'
        def_node_matcher :extend_self_node?, '(send nil :extend self)'

        def on_module(node)
          _name, body = *node
          return unless body && body.begin_type?

          each_wrong_style(body.children) do |child_node, msg|
            add_offense(child_node, :expression, msg)
          end
        end

        private

        def each_wrong_style(nodes)
          case style
          when :module_function
            nodes.each do |node|
              yield node, MODULE_FUNCTION_MSG if extend_self_node?(node)
            end
          when :extend_self
            nodes.each do |node|
              yield node, EXTEND_SELF_MSG if module_function_node?(node)
            end
          end
        end
      end
    end
  end
end
