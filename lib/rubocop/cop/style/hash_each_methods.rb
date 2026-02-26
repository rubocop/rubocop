# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of `each_key` and `each_value` Hash methods.
      #
      # NOTE: If you have an array of two-element arrays, you can put
      #   parentheses around the block arguments to indicate that you're not
      #   working with a hash, and suppress RuboCop offenses.
      #
      # @example
      #   # bad
      #   hash.keys.each { |k| p k }
      #   hash.values.each { |v| p v }
      #
      #   # good
      #   hash.each_key { |k| p k }
      #   hash.each_value { |v| p v }
      class HashEachMethods < Base
        include Lint::UnusedArgument
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'

        # @!method kv_each(node)
        def_node_matcher :kv_each, <<~PATTERN
          (block $(send (send _ ${:keys :values}) :each) ...)
        PATTERN

        def on_block(node)
          register_kv_offense(node)
        end

        private

        def register_kv_offense(node)
          kv_each(node) do |target, method|
            return unless target.receiver.receiver

            msg = format(message, prefer: "each_#{method[0..-2]}",
                                  current: "#{method}.each")

            add_offense(kv_range(target), message: msg) do |corrector|
              correct_key_value_each(target, corrector)
            end
          end
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

          new_source = receiver.source + ".#{name}"
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
