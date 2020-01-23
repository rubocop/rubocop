# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of `_.each_with_object({}) {...}`,
      # `_.map{...}.to_h`, and `Hash[_.map{...}]` that are actually just
      # transforming either the keys or the values of a hash, and tries to use
      # a simpler & faster call to `transform_keys` or `transform_values`
      # instead.
      #
      # This can produce false positives if we are transforming an enumerable
      # of key-value-like pairs that isn't actually a hash, e.g.:
      # `[[k1, v1], [k2, v2], ...]`
      #
      # This cop should only be enabled on Ruby version 2.5 or newer
      # (`transform_values` was added in 2.4, and `transform_keys` in 2.5.)
      #
      # @example
      #   # bad
      #   {a: 1, b: 2}.each_with_object({}) { |(k, v), h| h[k] = v*v }
      #   {a: 1, b: 2}.map { |k, v| [k.to_s, v] }
      #
      #   # good
      #   {a: 1, b: 2}.transform_values { |v| v*v }
      #   {a: 1, b: 2}.transform_keys { |k| k.to_s }
      class HashTransformMethods < Cop
        extend TargetRubyVersion

        minimum_target_ruby_version 2.5

        EACH_WITH_OBJECT_PATTERN = NodePattern.new(<<~PATTERN)
          (block
            ({send csend} _ :each_with_object (hash))
            (args
              (mlhs
                (arg $_)
                (arg $_))
              (arg $_))
            ({send csend} (lvar $_) :[]= $_ $_))
        PATTERN

        HASH_BRACKETS_MAP_PATTERN = NodePattern.new(<<~PATTERN)
          (send
            (const _ :Hash)
            :[]
            (block
              ({send csend} _ :map)
              (args
                (arg $_)
                (arg $_))
              (array $_ $_)))
        PATTERN

        MAP_TO_H_PATTERN = NodePattern.new(<<~PATTERN)
          ({send csend}
            (block
              ({send csend} _ :map)
              (args
                (arg $_)
                (arg $_))
              (array $_ $_))
            :to_h)
        PATTERN

        VALS_MSG = 'Use `transform_values` to transform just the values of a ' \
                   'hash, rather than `each_with_object` or `map`'
        KEYS_MSG = 'Use `transform_keys` to transform just the keys of a ' \
                   'hash, rather than `each_with_object` or `map`'

        def on_block(node)
          match = EACH_WITH_OBJECT_PATTERN.match(node)
          return unless match

          k_arg, v_arg, hash_arg, hash_body, k_body, v_body = *match
          return unless hash_arg == hash_body

          handle_possible_offense(node, k_arg, v_arg, k_body, v_body)
        end

        def on_send(node)
          match = (
            HASH_BRACKETS_MAP_PATTERN.match(node) ||
            MAP_TO_H_PATTERN.match(node)
          )
          handle_possible_offense(node, *match) if match
        end

        def on_csend(node)
          match = MAP_TO_H_PATTERN.match(node)
          handle_possible_offense(node, *match) if match
        end

        def autocorrect(node)
          lambda do |corrector|
            correction = preprocess_by_match_type_for_autocorrect(
              node,
              corrector
            )
            correction.apply(corrector)
          end
        end

        private

        def handle_possible_offense(node, k_arg, v_arg, k_body, v_body)
          unchanged_key = unchanged_key_or_val?(k_body, k_arg)
          unchanged_val = unchanged_key_or_val?(v_body, v_arg)

          # If both key and value are changed, this block can't be replaced.
          # If neither is changed, this is either a false positive (receiver
          # isn't a hash) or very weird; either way ignore it.
          return if unchanged_key == unchanged_val

          # Can't use `transform_values` if value transformation uses key,
          # or `transform_keys` if key transformation uses value
          if unchanged_key && !v_body.descendants.include?(k_body)
            add_offense(node, message: VALS_MSG)
          elsif unchanged_val && !k_body.descendants.include?(v_body)
            add_offense(node, message: KEYS_MSG)
          end
        end

        def unchanged_key_or_val?(body, arg)
          body.lvar_type? && body.children == [arg]
        end

        def preprocess_by_match_type_for_autocorrect(node, corrector) # rubocop:disable Metrics/AbcSize
          if (match = EACH_WITH_OBJECT_PATTERN.match(node))
            each_with_object_autocorrect_data(node, match)
          elsif (match = HASH_BRACKETS_MAP_PATTERN.match(node))
            corrector.remove_leading(node.loc.expression, 'Hash['.length) # rubocop:disable Performance/FixedSize
            corrector.remove_trailing(node.loc.expression, ']'.length) # rubocop:disable Performance/FixedSize

            hash_brackets_map_autocorrect_data(node, match)
          elsif (match = MAP_TO_H_PATTERN.match(node))
            corrector.remove_trailing(node.loc.expression, '.to_h'.length) # rubocop:disable Performance/FixedSize

            map_to_h_autocorrect_data(node, match)
          else
            raise 'unreachable'
          end
        end

        def each_with_object_autocorrect_data(node, match)
          _, _, _, _, k_body, v_body = *match
          k_arg, v_arg = *node.arguments.first.children
          Autocorrection.new(node, k_arg, v_arg, k_body, v_body)
        end

        def hash_brackets_map_autocorrect_data(node, match)
          _, _, k_body, v_body = *match
          block_node = node.children.last
          k_arg, v_arg = *block_node.arguments
          Autocorrection.new(block_node, k_arg, v_arg, k_body, v_body)
        end

        def map_to_h_autocorrect_data(node, match)
          _, _, k_body, v_body = *match
          block_node = node.children.first
          k_arg, v_arg = *block_node.arguments
          Autocorrection.new(block_node, k_arg, v_arg, k_body, v_body)
        end

        # Internal helper class to represent a planned autocorrection
        class Autocorrection
          def initialize(node, k_arg, v_arg, k_body, v_body)
            @node = node

            # Use `transform_values` if the key wasn't transformed, & vice versa
            if k_body.lvar_type?
              @new_method = 'transform_values'
              @new_arg = v_arg
              @new_body = v_body
            else
              @new_method = 'transform_keys'
              @new_arg = k_arg
              @new_body = k_body
            end
          end

          def apply(corrector)
            corrector.replace(method_call_range_to_replace, @new_method)
            corrector.replace(arg_range_to_replace, "|#{new_arg_source}|")
            corrector.replace(body_range_to_replace, new_body_source)
          end

          private

          def body_range_to_replace
            @node.body.loc.expression
          end

          def new_body_source
            @new_body.loc.expression.source
          end

          def arg_range_to_replace
            @node.arguments.loc.expression
          end

          def new_arg_source
            @new_arg.loc.expression.source
          end

          def method_call_range_to_replace
            range = @node.send_node.loc.selector
            if (send_end = @node.send_node.loc.end)
              # If there are arguments (only true in the `each_with_object`
              # case)
              range.begin.join(send_end)
            else
              range
            end
          end
        end

        private_constant :Autocorrection
      end
    end
  end
end
