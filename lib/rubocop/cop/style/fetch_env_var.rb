# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop suggests `ENV.fetch` for the replacement of `ENV[]`.
      # `ENV[]` silently fails and returns `nil` when the environment variable is unset,
      # which may cause unexpected behaviors when the developer forgets to set it.
      # On the other hand, `ENV.fetch` raises KeyError or returns the explicitly
      # specified default value.
      #
      # @example
      #   # bad
      #   ENV['X']
      #   ENV['X'] || z
      #   x = ENV['X']
      #
      #   # good
      #   ENV.fetch('X')
      #   ENV.fetch('X', nil) || z
      #   x = ENV.fetch('X')
      #
      #   # also good
      #   !ENV['X']
      #   ENV['X'].some_method # (e.g. `.nil?`)
      #
      class FetchEnvVar < Base
        extend AutoCorrector

        MSG = 'Use `ENV.fetch(%<key>s)` or `ENV.fetch(%<key>s, nil)` instead of `ENV[%<key>s]`.'

        # @!method env_with_bracket?(node)
        def_node_matcher :env_with_bracket?, <<~PATTERN
          (send (const nil? :ENV) :[] $_)
        PATTERN

        def on_send(node)
          env_with_bracket?(node) do |expression|
            break if allowed_var?(expression)
            break unless offensive?(node)

            add_offense(node, message: format(MSG, key: expression.source)) do |corrector|
              corrector.replace(node, "ENV.fetch(#{expression.source}, nil)")
            end
          end
        end

        private

        def allowed_var?(expression)
          expression.str_type? && cop_config['AllowedVars'].include?(expression.value)
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def offensive?(node)
          only_node_of_expression?(node) ||
            method_argument?(node) ||
            array_element?(node) ||
            hash_key?(node) ||
            compared?(node) ||
            case?(node) ||
            operand_of_or?(node) ||
            last_child_of_parent_node?(node)
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def case?(node)
          node.parent&.case_type? || node.parent&.when_type?
        end

        def only_node_of_expression?(node)
          node.parent.nil?
        end

        def method_argument?(node)
          return false unless node.parent&.send_type?

          node.parent.arguments.include?(node)
        end

        def array_element?(node)
          return false unless node.parent&.array_type?

          node.parent.children.include?(node)
        end

        def hash_key?(node)
          return false unless node.parent&.pair_type?

          node.parent.children.first == node
        end

        def compared?(node)
          return false unless node.parent&.send_type?

          node.parent.comparison_method?
        end

        def operand_of_or?(node)
          return false unless node.parent&.or_type?

          node.parent.children.include?(node)
        end

        def last_child_of_parent_node?(node)
          return false unless node.parent

          node.parent.children.last == node
        end
      end
    end
  end
end
