# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that node matcher definitions are named like predicates
      # if and only if they contain no captures.
      #
      # @example
      #  # bad
      #  def_node_matcher :string_content?, <<~PATTERN
      #    (str $_)
      #  PATTERN
      #
      #  # good
      #  def_node_matcher :string_content, <<~PATTERN
      #    (str $_)
      #  PATTERN
      #
      class NodeMatcherNaming < Base
        extend AutoCorrector
        include RangeHelp

        MSG_PREDICATE     = 'Node matcher without captures should be a predicate.'
        MSG_NOT_PREDICATE = 'Node matcher with captures should not be a predicate.'

        RESTRICT_ON_SEND = [:def_node_matcher].freeze

        # @!method pattern_matcher?(node)
        def_node_matcher :pattern_matcher?, <<~PATTERN
          (send nil? :def_node_matcher {str sym} (str _))
        PATTERN

        # rubocop:disable Metrics
        def on_send(node)
          return unless pattern_matcher?(node)

          actual_name = node.first_argument.value.to_s

          pattern = RuboCop::AST::NodePattern.new(node.arguments[1].value)

          should_be_predicate = pattern.captures.zero?
          is_predicate        = actual_name.end_with?('?')

          if should_be_predicate && !is_predicate
            message  = MSG_PREDICATE
            new_name = "#{actual_name}?"
          elsif !should_be_predicate && is_predicate
            message  = MSG_NOT_PREDICATE
            new_name = actual_name.chop
          end

          return unless message

          add_offense(node.first_argument, message: message) do |corrector|
            correct_name(corrector, node.first_argument, new_name)
          end
        end
        # rubocop:enable Metrics

        private

        def correct_name(corrector, name_node, new_name)
          replacement = name_node.sym_type? ? ":#{new_name}" : "'#{new_name}'"
          corrector.replace(name_node, replacement)
        end
      end
    end
  end
end
