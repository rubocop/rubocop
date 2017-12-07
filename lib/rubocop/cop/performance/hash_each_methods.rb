# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop checks for uses of `each_key` and `each_value` Hash methods.
      #
      # Note: If you have an array of two-element arrays, you can put
      #   parentheses around the block arguments to indicate that you're not
      #   working with a hash, and suppress RuboCop offenses.
      #
      # @example
      #   # bad
      #   hash.keys.each { |k| p k }
      #   hash.values.each { |v| p v }
      #   hash.each { |k, _v| p k }
      #   hash.each { |_k, v| p v }
      #
      #   # good
      #   hash.each_key { |k| p k }
      #   hash.each_value { |v| p v }
      class HashEachMethods < Cop
        include Lint::UnusedArgument

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        def_node_matcher :plain_each, <<-PATTERN
          (block $(send !(send _ :to_a) :each) (args $(arg _k) $(arg _v)) ...)
        PATTERN

        def_node_matcher :kv_each, <<-PATTERN
          (block $(send (send _ ${:keys :values}) :each) ...)
        PATTERN

        def on_block(node)
          register_each_offense(node)
          register_kv_offense(node)
        end

        private

        def register_each_offense(node)
          plain_each(node) do |target, k, v|
            return if used?(k) && used?(v)
            used = used?(k) ? :key : :value

            add_offense(
              target,
              location: plain_range(target),
              message: format(message, prefer: "each_#{used}", current: :each)
            )
          end
        end

        def register_kv_offense(node)
          kv_each(node) do |target, method|
            msg = format(message, prefer: "each_#{method[0..-2]}",
                                  current: "#{method}.each")

            add_offense(target, location: kv_range(target), message: msg)
          end
        end

        def check_argument(variable)
          return unless variable.block_argument?
          (@block_args ||= []).push(variable)
        end

        def used?(arg)
          loc = arg.loc
          variable = @block_args.find { |var| var.declaration_node.loc == loc }
          variable.used?
        end

        def autocorrect(node)
          receiver = node.receiver
          _caller, first_method = *receiver

          lambda do |corrector|
            case first_method
            when :keys, :values
              correct_key_value_each(node, corrector)
            else
              correct_plain_each(node, corrector)
            end
          end
        end

        def correct_implicit(node, corrector, method_name)
          corrector.replace(node.loc.expression, method_name)
          correct_args(node, corrector)
        end

        def correct_key_value_each(node, corrector)
          receiver = node.receiver.receiver
          name = "each_#{node.receiver.method_name.to_s.chop}"
          return correct_implicit(node, corrector, name) unless receiver

          new_source = receiver.source + ".#{name}"
          corrector.replace(node.loc.expression, new_source)
        end

        def correct_plain_each(node, corrector)
          _each, key, _value = plain_each(node.parent)
          name = used?(key) ? 'each_key' : 'each_value'
          return correct_implicit(node, corrector, name) unless node.receiver

          corrector.replace(node.loc.selector, name)
          correct_args(node, corrector)
        end

        def correct_args(node, corrector)
          args = node.parent.arguments
          name, = *args.children.find { |arg| used?(arg) }

          corrector.replace(args.source_range, "|#{name}|")
        end

        def plain_range(outer_node)
          outer_node.loc.selector
        end

        def kv_range(outer_node)
          outer_node.receiver.loc.selector.join(outer_node.loc.selector)
        end
      end
    end
  end
end
