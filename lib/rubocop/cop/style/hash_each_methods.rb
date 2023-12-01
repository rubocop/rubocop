# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `each_key` and `each_value` Hash methods.
      #
      # NOTE: If you have an array of two-element arrays, you can put
      #   parentheses around the block arguments to indicate that you're not
      #   working with a hash, and suppress RuboCop offenses.
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver
      #   is a `Hash`. The `AllowedReceivers` configuration can mitigate,
      #   but not fully resolve, this safety issue.
      #
      # @example
      #   # bad
      #   hash.keys.each { |k| p k }
      #   hash.each { |k, unused_value| p k }
      #
      #   # good
      #   hash.each_key { |k| p k }
      #
      #   # bad
      #   hash.values.each { |v| p v }
      #   hash.each { |unused_key, v| p v }
      #
      #   # good
      #   hash.each_value { |v| p v }
      #
      # @example AllowedReceivers: ['execute']
      #   # good
      #   execute(sql).keys.each { |v| p v }
      #   execute(sql).values.each { |v| p v }
      class HashEachMethods < Base
        include AllowedReceivers
        include Lint::UnusedArgument
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'
        UNUSED_BLOCK_ARG_MSG = "#{MSG.chop} and remove the unused `%<unused_code>s` block argument."

        # @!method kv_each(node)
        def_node_matcher :kv_each, <<~PATTERN
          ({block numblock} $(call (call _ ${:keys :values}) :each) ...)
        PATTERN

        # @!method each_arguments(node)
        def_node_matcher :each_arguments, <<~PATTERN
          (block (call _ :each)(args $_key $_value) ...)
        PATTERN

        # @!method kv_each_with_block_pass(node)
        def_node_matcher :kv_each_with_block_pass, <<~PATTERN
          (call $(call _ ${:keys :values}) :each (block_pass (sym _)))
        PATTERN

        # rubocop:disable Metrics/AbcSize
        def on_block(node)
          kv_each(node) do |target, method|
            register_kv_offense(target, method) and return
          end

          return unless (key, value = each_arguments(node))

          if unused_block_arg_exist?(node, value.source)
            message = message('each_key', node.method_name, value.source)
            unused_range = key.source_range.end.join(value.source_range.end)

            register_each_args_offense(node, message, 'each_key', unused_range)
          elsif unused_block_arg_exist?(node, key.source)
            message = message('each_value', node.method_name, key.source)
            unused_range = key.source_range.begin.join(value.source_range.begin)

            register_each_args_offense(node, message, 'each_value', unused_range)
          end
        end
        # rubocop:enable Metrics/AbcSize

        alias on_numblock on_block

        def on_block_pass(node)
          kv_each_with_block_pass(node.parent) do |target, method|
            register_kv_with_block_pass_offense(node, target, method)
          end
        end

        private

        def register_kv_offense(target, method)
          return unless (parent_receiver = target.receiver.receiver)
          return if allowed_receiver?(parent_receiver)

          current = target.receiver.loc.selector.join(target.source_range.end).source

          add_offense(kv_range(target), message: format_message(method, current)) do |corrector|
            correct_key_value_each(target, corrector)
          end
        end

        def unused_block_arg_exist?(node, block_arg_source)
          node.body.each_descendant(:lvar).map(&:source).none?(block_arg_source)
        end

        def message(prefer, method_name, unused_code)
          format(
            UNUSED_BLOCK_ARG_MSG, prefer: prefer, current: method_name, unused_code: unused_code
          )
        end

        def register_each_args_offense(node, message, prefer, unused_range)
          add_offense(node, message: message) do |corrector|
            corrector.replace(node.send_node.loc.selector, prefer)
            corrector.remove(unused_range)
          end
        end

        def register_kv_with_block_pass_offense(node, target, method)
          return unless (parent_receiver = node.parent.receiver.receiver)
          return if allowed_receiver?(parent_receiver)

          range = target.loc.selector.join(node.parent.loc.selector.end)

          add_offense(range, message: format_message(method, range.source)) do |corrector|
            corrector.replace(range, "each_#{method[0..-2]}")
          end
        end

        def format_message(method_name, current)
          format(MSG, prefer: "each_#{method_name[0..-2]}", current: current)
        end

        def check_argument(variable)
          return unless variable.block_argument?

          (@block_args ||= []).push(variable)
        end

        def used?(arg)
          @block_args.find { |var| var.declaration_node.loc == arg.loc }.used?
        end

        def correct_implicit(node, corrector, method_name)
          corrector.replace(node, method_name)
          correct_args(node, corrector)
        end

        def correct_key_value_each(node, corrector)
          receiver = node.receiver.receiver
          name = "each_#{node.receiver.method_name.to_s.chop}"
          return correct_implicit(node, corrector, name) unless receiver

          new_source = receiver.source + "#{node.loc.dot.source}#{name}"
          corrector.replace(node, new_source)
        end

        def correct_args(node, corrector)
          args = node.parent.arguments
          name, = *args.children.find { |arg| used?(arg) }

          corrector.replace(args, "|#{name}|")
        end

        def kv_range(outer_node)
          outer_node.receiver.loc.selector.join(outer_node.loc.selector)
        end
      end
    end
  end
end
