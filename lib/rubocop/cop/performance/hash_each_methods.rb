# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop checks for uses of `each_key` and `each_value` Hash methods.
      #
      # Note: If you have an array of two-element arrays, you can put
      #   parentheses around the block arguments to indicate that you're not
      #   working with a hash, and supress RuboCop offenses.
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

        MSG = 'Use `%s` instead of `%s`.'.freeze

        def_node_matcher :plain_each, <<-PATTERN
          (block $(send !(send _ :to_a) :each) (args (arg $_k) (arg $_v)) ...)
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
            return if @args[k] && @args[v]
            used = @args[k] ? :key : :value
            add_offense(
              target, plain_range(target), format(message,
                                                  "each_#{used}",
                                                  :each)
            )
          end
        end

        def register_kv_offense(node)
          kv_each(node) do |target, method|
            add_offense(
              target, kv_range(target), format(message,
                                               "each_#{method[0..-2]}",
                                               "#{method}.each")
            )
          end
        end

        def check_argument(variable)
          return unless variable.block_argument?
          (@args ||= {})[variable.name] = variable.used?
        end

        def autocorrect(node)
          receiver, _second_method = *node
          _caller, first_method = *receiver

          lambda do |corrector|
            case first_method
            when :keys, :values
              return correct_implicit(node, corrector) if receiver.receiver.nil?

              correct_key_value_each(node, corrector)
            else
              return correct_implicit(node, corrector) if receiver.nil?

              correct_plain_each(node, corrector)
            end
          end
        end

        def correct_implicit(node, corrector)
          method = @args.include?(:k) ? :key : :value
          new_source = "each_#{method}"

          corrector.replace(node.loc.expression, new_source)
          correct_args(node, corrector)
        end

        def correct_key_value_each(node, corrector)
          receiver = node.receiver

          new_source = receiver.receiver.source +
                       ".each_#{receiver.method_name[0..-2]}"
          corrector.replace(node.loc.expression, new_source)
        end

        def correct_plain_each(node, corrector)
          method = @args.include?(:k) ? :key : :value
          new_source = node.receiver.source + ".each_#{method}"

          corrector.replace(node.loc.expression, new_source)
          correct_args(node, corrector)
        end

        def correct_args(node, corrector)
          args = node.parent.children[1]
          used_arg = "|#{@args.detect { |_k, v| v }.first}|"

          corrector.replace(args.source_range, used_arg)
        end

        def plain_range(outer_node)
          outer_node.loc.selector
        end

        def kv_range(outer_node)
          inner_node = outer_node.children.first
          inner_node.loc.selector.join(outer_node.loc.selector)
        end
      end
    end
  end
end
