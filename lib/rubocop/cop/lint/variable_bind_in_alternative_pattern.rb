# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Binding variables in alternative patterns joined with `|`
      # raises SyntaxError when executed.
      #
      # @example
      #
      #   # bad
      #   case {a: 1, b: 2}
      #   in {a: } | Array
      #     "matched: #{a}"
      #   else
      #     "not matched"
      #   end
      #
      #   # good
      #   foo = 1
      #   case x
      #   in ^foo | Array
      #     do_something
      #   end
      #
      class VariableBindInAlternativePattern < Base
        extend TargetRubyVersion

        MSG = 'Do not bind variables in alternative patterns.'

        minimum_target_ruby_version 2.7

        def on_match_alt(match_node)
          add_offense(match_node) if match_node.descendants.any?(&:match_var_type?)
        end
      end
    end
  end
end
