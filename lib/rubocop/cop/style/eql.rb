# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `eql?` when `==` will do.
      # The stricter comparison semantics provided by `eql?` are rarely
      # needed in practice.
      #
      # Calls without a receiver or without exactly one argument are not
      # checked, and calls inside a definition of `eql?` are allowed, as
      # delegating to another object's `eql?` is a common way to implement it.
      #
      # @safety
      #   This cop is unsafe because `eql?` and `==` are not equivalent in
      #   general: `eql?` never converts between numeric types, so
      #   `1.eql?(1.0)` is `false` while `1 == 1.0` is `true`, and classes
      #   may redefine either method independently. Additionally, safe
      #   navigation calls are not autocorrected since `nil&.eql?(other)`
      #   returns `nil` whereas `nil == other` returns `true` or `false`.
      #
      # @example
      #   # bad
      #   'ruby'.eql?(some_str)
      #
      #   # good
      #   'ruby' == some_str
      #
      class Eql < Base
        extend AutoCorrector

        MSG = 'Use `==` instead of `eql?`.'
        RESTRICT_ON_SEND = %i[eql?].freeze

        INVALID_SYNTAX_ARG_TYPES = %i[splat forwarded_args forwarded_restarg block_pass].freeze

        def on_send(node)
          return unless node.receiver && node.arguments.one?
          return if within_eql_definition?(node)

          add_offense(node) do |corrector|
            autocorrect(corrector, node) if autocorrectable?(node)
          end
        end
        alias on_csend on_send

        private

        def autocorrectable?(node)
          return false if node.csend_type? || node.block_node

          argument = node.first_argument
          return false if INVALID_SYNTAX_ARG_TYPES.include?(argument.type)

          !argument.hash_type? || argument.braces?
        end

        def autocorrect(corrector, node)
          replacement = "#{node.receiver.source} == #{node.first_argument.source}"
          replacement = "(#{replacement})" if requires_parentheses?(node)
          corrector.replace(node, replacement)
        end

        def within_eql_definition?(node)
          node.each_ancestor(:any_def).any? { |ancestor| ancestor.method?(:eql?) }
        end

        def requires_parentheses?(node)
          parent = node.parent
          return false unless parent&.call_type?

          parent.receiver == node || parent.operator_method?
        end
      end
    end
  end
end
