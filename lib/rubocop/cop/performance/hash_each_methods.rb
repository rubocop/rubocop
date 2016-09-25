# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop checks for uses of `each_key` & `each_value` Hash methods.
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

        def_node_matcher :plain_each, <<-END
          (block $(send (send _ :hash) :each) (args (arg $_k) (arg $_v)) ...)
        END

        def_node_matcher :kv_each, <<-END
          (block $(send (send (send _ :hash) ${:keys :values}) :each) ...)
        END

        def on_block(node)
          plain_each(node) do |target, k, v|
            return if @args[k] && @args[v]
            used = @args[k] ? :key : :value
            add_offense(target, range(target), format(message,
                                                      "each_#{used}",
                                                      :each))
          end
          kv_each(node) do |target, method|
            add_offense(target, range(target), format(message,
                                                      "each_#{method[0..-2]}",
                                                      "#{method}.each"))
          end
        end

        def check_argument(variable)
          return unless variable.block_argument?
          (@args ||= {})[variable.name] = variable.used?
        end

        def autocorrect(node)
          receiver, _second_method = *node
          caller, first_method = *receiver
          lambda do |corrector|
            if first_method == :hash
              method = @args.values.first ? :key : :value
              new_source = receiver.source + ".each_#{method}"
              corrector.replace(node.loc.expression, new_source)
              correct_args(node, corrector)
            else
              new_source = caller.source + ".each_#{first_method[0..-2]}"
              corrector.replace(node.loc.expression, new_source)
            end
          end
        end

        private

        def correct_args(node, corrector)
          args = node.parent.children[1]
          used_arg = "|#{@args.detect { |_k, v| v }.first}|"
          args_range = range_between(args.loc.begin.begin_pos,
                                     args.loc.end.end_pos)
          corrector.replace(args_range, used_arg)
        end

        def range(outer_node)
          inner_node = outer_node.children.first
          inner_node.loc.selector.join(outer_node.loc.selector)
        end
      end
    end
  end
end
