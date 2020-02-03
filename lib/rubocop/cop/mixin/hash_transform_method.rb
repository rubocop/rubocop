# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Style/HashTransformKeys and
    # Style/HashTransformValues
    module HashTransformMethod
      def on_block(node)
        on_bad_each_with_object(node) do |*match|
          handle_possible_offense(node, match, 'each_with_object')
        end
      end

      def on_send(node)
        on_bad_hash_brackets_map(node) do |*match|
          handle_possible_offense(node, match, 'Hash[_.map {...}]')
        end
        on_bad_map_to_h(node) do |*match|
          handle_possible_offense(node, match, 'map {...}.to_h')
        end
      end

      def on_csend(node)
        on_bad_map_to_h(node) do |*match|
          handle_possible_offense(node, match, 'map {...}.to_h')
        end
      end

      def autocorrect(node)
        lambda do |corrector|
          correction = prepare_correction(node)
          execute_correction(corrector, node, correction)
        end
      end

      private

      # @abstract Implemented with `def_node_matcher`
      def on_bad_each_with_object(_node)
        raise NotImplementedError
      end

      # @abstract Implemented with `def_node_matcher`
      def on_bad_hash_brackets_map(_node)
        raise NotImplementedError
      end

      # @abstract Implemented with `def_node_matcher`
      def on_bad_map_to_h(_node)
        raise NotImplementedError
      end

      def handle_possible_offense(node, match, match_desc)
        captures = extract_captures(match)

        # If key didn't actually change either, this is most likely a false
        # positive (receiver isn't a hash).
        return if captures.noop_transformation?

        # Can't `transform_keys` if key transformation uses value, or
        # `transform_values` if value transformation uses key.
        return if captures.transformation_uses_both_args?

        add_offense(
          node,
          message: "Prefer `#{new_method_name}` over `#{match_desc}`."
        )
      end

      # @abstract
      #
      # @return [Captures]
      def extract_captures(_match)
        raise NotImplementedError
      end

      # @abstract
      #
      # @return [String]
      def new_method_name
        raise NotImplementedError
      end

      def prepare_correction(node)
        on_bad_each_with_object(node) do |*match|
          return Autocorrection.new(match, node, 0, 0)
        end

        on_bad_hash_brackets_map(node) do |*match|
          block = node.children.last
          return Autocorrection.new(match, block, 'Hash['.length, ']'.length)
        end

        on_bad_map_to_h(node) do |*match|
          block = node.children.first
          return Autocorrection.new(match, block, 0, '.to_h'.length)
        end
      end

      def execute_correction(corrector, node, correction) # rubocop:disable Metrics/AbcSize
        root_expression = node.loc.expression
        corrector.remove_leading(root_expression, correction.leading)
        corrector.remove_trailing(root_expression, correction.trailing)

        corrector.replace(correction.method_call_range, new_method_name)

        captures = extract_captures(correction.match)
        corrector.replace(correction.arg_range, new_arg_source(captures))
        corrector.replace(correction.body_range, new_body_source(captures))
      end

      def new_arg_source(captures)
        "|#{captures.transformed_argname}|"
      end

      def new_body_source(captures)
        captures.transforming_body_expr.loc.expression.source
      end

      # Internal helper class to hold match data
      Captures = Struct.new(
        :transformed_argname,
        :transforming_body_expr,
        :unchanged_body_expr
      ) do
        def noop_transformation?
          transforming_body_expr.lvar_type? &&
            transforming_body_expr.children == [transformed_argname]
        end

        def transformation_uses_both_args?
          transforming_body_expr.descendants.include?(unchanged_body_expr)
        end
      end

      # Internal helper class to hold autocorrect data
      Autocorrection = Struct.new(:match, :block_node, :leading, :trailing) do
        def method_call_range
          range = block_node.send_node.loc.selector
          if (send_end = block_node.send_node.loc.end)
            # If there are arguments (only true in the `each_with_object`
            # case)
            range.begin.join(send_end)
          else
            range
          end
        end

        def arg_range
          block_node.arguments.loc.expression
        end

        def body_range
          block_node.body.loc.expression
        end
      end
    end
  end
end
