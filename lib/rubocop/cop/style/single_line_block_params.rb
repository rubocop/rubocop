# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the block parameters of a single-line
      # method accepting a block match the names specified via configuration.
      #
      # For instance one can configure `reduce`(`inject`) to use |a, e| as
      # parameters.
      #
      # Configuration option: Methods
      # Should be set to use this cop. Array of hashes, where each key is the
      # method name and value - array of argument names.
      #
      # @example Methods: [{reduce: %w[a b]}]
      #   # bad
      #   foo.reduce { |c, d| c + d }
      #   foo.reduce { |_, _d| 1 }
      #
      #   # good
      #   foo.reduce { |a, b| a + b }
      #   foo.reduce { |a, _b| a }
      #   foo.reduce { |a, (id, _)| a + id }
      #   foo.reduce { true }
      #
      #   # good
      #   foo.reduce do |c, d|
      #     c + d
      #   end
      class SingleLineBlockParams < Base
        MSG = 'Name `%<method>s` block params `|%<params>s|`.'

        def on_block(node)
          return unless node.single_line?

          return unless eligible_method?(node)
          return unless eligible_arguments?(node)

          return if args_match?(node.send_node.method_name, node.arguments)

          message = message(node.arguments)

          add_offense(node.arguments, message: message)
        end

        private

        def message(node)
          method_name = node.parent.send_node.method_name
          arguments   = target_args(method_name).join(', ')

          format(MSG, method: method_name, params: arguments)
        end

        def eligible_arguments?(node)
          node.arguments? && node.arguments.to_a.all?(&:arg_type?)
        end

        def eligible_method?(node)
          node.send_node.receiver &&
            method_names.include?(node.send_node.method_name)
        end

        def methods
          cop_config['Methods']
        end

        def method_names
          methods.map { |method| method_name(method).to_sym }
        end

        def method_name(method)
          method.keys.first
        end

        def target_args(method_name)
          method_name = method_name.to_s
          method_hash = methods.find { |m| method_name(m) == method_name }
          method_hash[method_name]
        end

        def args_match?(method_name, args)
          actual_args = args.to_a.flat_map(&:to_a)

          # Prepending an underscore to mark an unused parameter is allowed, so
          # we remove any leading underscores before comparing.
          actual_args_no_underscores = actual_args.map do |arg|
            arg.to_s.sub(/^_+/, '')
          end

          actual_args_no_underscores == target_args(method_name)
        end
      end
    end
  end
end
