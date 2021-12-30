# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # In Ruby 3.1, anonymous block forwarding has been added.
      #
      # This cop identifies places where `do_something(&block)` can be replaced
      # by `do_something(&)`.
      #
      # It also supports the opposite style by alternative `explicit` option.
      #
      # @example EnforcedStyle: anonymous (default)
      #
      #   # bad
      #   def foo(&block)
      #     bar(&block)
      #   end
      #
      #   # good
      #   def foo(&)
      #     bar(&)
      #   end
      #
      # @example EnforcedStyle: explicit
      #
      #   # bad
      #   def foo(&)
      #     bar(&)
      #   end
      #
      #   # good
      #   def foo(&block)
      #     bar(&block)
      #   end
      #
      class BlockForwarding < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 3.1

        MSG = 'Use %<style>s block forwarding.'

        def on_def(node)
          return if node.arguments.empty?

          last_argument = node.arguments.last
          return if expected_block_forwarding_style?(node, last_argument)

          register_offense(last_argument)

          node.each_descendant(:block_pass) do |block_pass_node|
            next if block_pass_node.children.first&.sym_type?

            register_offense(block_pass_node)
          end
        end
        alias on_defs on_def

        private

        def expected_block_forwarding_style?(node, last_argument)
          if style == :anonymous
            !explicit_block_argument?(last_argument) ||
              use_kwarg_in_method_definition?(node) ||
              use_block_argument_as_local_variable?(node, last_argument)
          else
            !anonymous_block_argument?(last_argument)
          end
        end

        def use_kwarg_in_method_definition?(node)
          node.arguments.each_descendant(:kwarg, :kwoptarg).any?
        end

        def anonymous_block_argument?(node)
          node.blockarg_type? && node.name.nil?
        end

        def explicit_block_argument?(node)
          node.blockarg_type? && !node.name.nil?
        end

        def use_block_argument_as_local_variable?(node, last_argument)
          return if node.body.nil?

          node.body.each_descendant(:lvar).any? do |lvar|
            !lvar.parent.block_pass_type? && lvar.source == last_argument.source[1..-1]
          end
        end

        def register_offense(block_argument)
          add_offense(block_argument, message: format(MSG, style: style)) do |corrector|
            corrector.replace(block_argument, '&')

            arguments = block_argument.parent

            add_parentheses(arguments, corrector) unless arguments.parenthesized_call?
          end
        end
      end
    end
  end
end
