# frozen_string_literal: true

module RuboCop
  module Cop
    # This module checks for Ruby 3.1's hash value omission syntax.
    module HashShorthandSyntax
      OMIT_HASH_VALUE_MSG = 'Omit the hash value.'
      EXPLICIT_HASH_VALUE_MSG = 'Explicit the hash value.'

      def on_pair(node)
        return if target_ruby_version <= 3.0

        hash_key_source = node.key.source

        if enforced_shorthand_syntax == 'always'
          return if node.value_omission? || require_hash_value?(hash_key_source, node)

          message = OMIT_HASH_VALUE_MSG
          replacement = "#{hash_key_source}:"
        else
          return unless node.value_omission?

          message = EXPLICIT_HASH_VALUE_MSG
          replacement = "#{hash_key_source}: #{hash_key_source}"
        end

        add_offense(node.value, message: message) do |corrector|
          corrector.replace(node, replacement)
        end
      end

      private

      def enforced_shorthand_syntax
        cop_config.fetch('EnforcedShorthandSyntax', 'always')
      end

      def require_hash_value?(hash_key_source, node)
        return true if without_parentheses_call_expr_follows?(node)

        hash_value = node.value
        return true unless hash_value.send_type? || hash_value.lvar_type?

        hash_key_source != hash_value.source || hash_key_source.end_with?('!', '?')
      end

      def without_parentheses_call_expr_follows?(node)
        return false unless (ancestor = node.parent.parent)
        return false unless (right_sibling = ancestor.right_sibling)

        ancestor.respond_to?(:parenthesized?) && !ancestor.parenthesized? &&
          right_sibling.respond_to?(:parenthesized?) && !right_sibling.parenthesized?
      end
    end
  end
end
