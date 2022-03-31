# frozen_string_literal: true

module RuboCop
  module Cop
    # This module checks for Ruby 3.1's hash value omission syntax.
    module HashShorthandSyntax
      OMIT_HASH_VALUE_MSG = 'Omit the hash value.'
      EXPLICIT_HASH_VALUE_MSG = 'Explicit the hash value.'

      def on_pair(node)
        return if ignore_hash_shorthand_syntax?(node)

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

      def ignore_hash_shorthand_syntax?(pair_node)
        target_ruby_version <= 3.0 || enforced_shorthand_syntax == 'either' ||
          !pair_node.parent.hash_type?
      end

      def enforced_shorthand_syntax
        cop_config.fetch('EnforcedShorthandSyntax', 'always')
      end

      def require_hash_value?(hash_key_source, node)
        return true if !node.key.sym_type? || require_hash_value_for_around_hash_literal?(node)

        hash_value = node.value
        return true unless hash_value.send_type? || hash_value.lvar_type?

        hash_key_source != hash_value.source || hash_key_source.end_with?('!', '?')
      end

      def require_hash_value_for_around_hash_literal?(node)
        return false unless (ancestor = node.parent.parent)
        return false if ancestor.send_type? && ancestor.method?(:[])

        !node.parent.braces? && !use_element_of_hash_literal_as_receiver?(ancestor, node.parent) &&
          (use_modifier_form_without_parenthesized_method_call?(ancestor) ||
           without_parentheses_call_expr_follows?(ancestor))
      end

      def use_element_of_hash_literal_as_receiver?(ancestor, parent)
        # `{value:}.do_something` is a valid syntax.
        ancestor.send_type? && ancestor.receiver == parent
      end

      def use_modifier_form_without_parenthesized_method_call?(ancestor)
        return false if ancestor.respond_to?(:parenthesized?) && ancestor.parenthesized?

        ancestor.ancestors.any? { |node| node.respond_to?(:modifier_form?) && node.modifier_form? }
      end

      def without_parentheses_call_expr_follows?(ancestor)
        right_sibling = ancestor.right_sibling
        right_sibling ||= ancestor.each_ancestor.find(&:assignment?)&.right_sibling
        return false unless right_sibling

        ancestor.respond_to?(:parenthesized?) && !ancestor.parenthesized? && !!right_sibling
      end
    end
  end
end
