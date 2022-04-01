# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop detects code that does not return default values nor
      # raise errors when reading unset environment variables.
      #
      # @example
      #   # bad
      #   ENV['X']
      #   y || ENV['X']
      #
      #   # good
      #   ENV.fetch('X', nil)
      #   y || ENV.fetch('X', nil)
      #
      #   # also good
      #   ENV['X'] || z
      #   !ENV['X']
      #   ENV['X'].some_method # (e.g. `.nil?`)
      #
      class ReadingEnvVarWithoutDefaultValue < Base
        extend AutoCorrector

        MSG = 'Use `ENV.fetch(%<key>s, nil)` instead of `ENV[%<key>s]`.'

        # @!method reading_env_without_default_val?(node)
        def_node_matcher :reading_env_without_default_val?, <<~PATTERN
          (send (const nil? :ENV) :[] $_)
        PATTERN

        def on_send(node)
          reading_env_without_default_val?(node) do |expression|
            break if excluded_env_var?(expression)
            break unless offensive?(node)

            add_offense(node, message: format(MSG, key: expression.source)) do |corrector|
              corrector.replace(node, "ENV.fetch(#{expression.source}, nil)")
            end
          end
        end

        private

        def excluded_env_var?(expression)
          expression.str_type? && cop_config['ExcludedEnvVars'].include?(expression.value)
        end

        def offensive?(node)
          only_node_of_expression?(node) ||
            method_argument?(node) ||
            array_element?(node) ||
            hash_key?(node) ||
            compared?(node) ||
            case?(node) ||
            last_child_of_parent_node?(node)
        end

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

        def last_child_of_parent_node?(node)
          return false unless node.parent

          node.parent.children.last == node
        end
      end
    end
  end
end
