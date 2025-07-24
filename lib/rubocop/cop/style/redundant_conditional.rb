# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant returning of true/false in conditionals.
      #
      # @example
      #   # bad
      #   x == y ? true : false
      #
      #   # bad
      #   if x == y
      #     true
      #   else
      #     false
      #   end
      #
      #   # good
      #   x == y
      #
      #   # bad
      #   x == y ? false : true
      #
      #   # good
      #   x != y
      #
      #   # bad
      #   x.nil? ? true : false
      #
      #   # good
      #   x.nil?
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: false (default)
      #   # good
      #   x.present? ? true : false
      #   x.blank? ? true : false
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: true
      #   # bad
      #   x.present? ? true : false
      #   x.blank? ? true : false
      #
      #   # good
      #   x.present?
      #   x.blank?
      #
      class RedundantConditional < Base
        include Alignment
        extend AutoCorrector

        MSG = 'This conditional expression can just be replaced by `%<msg>s`.'

        PREDICATE_METHODS = [:nil?].freeze
        ACTIVE_SUPPORT_PREDICATE_METHODS = (PREDICATE_METHODS + %i[present? blank?]).freeze

        def on_if(node)
          return unless offense?(node)

          message = message(node)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement_condition(node))
          end
        end

        private

        def message(node)
          replacement = replacement_condition(node)
          msg = node.elsif? ? "\n#{replacement}" : replacement

          format(MSG, msg: msg)
        end

        # @!method redundant_condition?(node)
        def_node_matcher :redundant_condition?, <<~PATTERN
          (if #boolean_expression? true false)
        PATTERN

        # @!method redundant_condition_inverted?(node)
        def_node_matcher :redundant_condition_inverted?, <<~PATTERN
          (if #boolean_expression? false true)
        PATTERN

        # @!method boolean_expression?(node)
        def_node_matcher :boolean_expression?, <<~PATTERN
          {
            (send _ %RuboCop::AST::Node::COMPARISON_OPERATORS _)
            (send _ #predicate_method?)
          }
        PATTERN

        def offense?(node)
          return false if node.modifier_form?

          redundant_condition?(node) || redundant_condition_inverted?(node)
        end

        def replacement_condition(node)
          expression = replacement_expression(node)

          node.elsif? ? indented_else_node(expression, node) : expression
        end

        def replacement_expression(node)
          condition = node.condition.source

          if redundant_condition?(node)
            condition
          elsif needs_parentheses?(node)
            "!(#{condition})"
          else
            "!#{condition}"
          end
        end

        def needs_parentheses?(node)
          !predicate_method?(node.condition.method_name)
        end

        def indented_else_node(expression, node)
          "else\n#{indentation(node)}#{expression}"
        end

        def predicate_method?(method_name)
          available_predicate_methods.include?(method_name)
        end

        def available_predicate_methods
          if active_support_extensions_enabled?
            ACTIVE_SUPPORT_PREDICATE_METHODS
          else
            PREDICATE_METHODS
          end
        end
      end
    end
  end
end
