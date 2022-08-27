# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of the case equality operator(===).
      #
      # If `AllowOnConstant` option is enabled, the cop will ignore violations when the receiver of
      # the case equality operator is a constant.
      #
      # @example
      #   # bad
      #   (1..100) === 7
      #   /something/ === some_string
      #
      #   # good
      #   something.is_a?(Array)
      #   (1..100).include?(7)
      #   /something/.match?(some_string)
      #
      # @example AllowOnConstant: false (default)
      #   # bad
      #   Array === something
      #
      # @example AllowOnConstant: true
      #   # good
      #   Array === something
      #
      class CaseEquality < Base
        extend AutoCorrector

        MSG = 'Avoid the use of the case equality operator `===`.'
        RESTRICT_ON_SEND = %i[===].freeze

        # @!method case_equality?(node)
        def_node_matcher :case_equality?, '(send $#const? :=== $_)'

        def on_send(node)
          case_equality?(node) do |lhs, rhs|
            return if lhs.const_type? && !lhs.module_name?

            add_offense(node.loc.selector) do |corrector|
              replacement = replacement(lhs, rhs)
              corrector.replace(node, replacement) if replacement
            end
          end
        end

        private

        def const?(node)
          if cop_config.fetch('AllowOnConstant', false)
            !node&.const_type?
          else
            true
          end
        end

        def replacement(lhs, rhs)
          case lhs.type
          when :regexp
            # The automatic correction from `a === b` to `a.match?(b)` needs to
            # consider `Regexp.last_match?`, `$~`, `$1`, and etc.
            # This correction is expected to be supported by `Performance/Regexp` cop.
            # See: https://github.com/rubocop/rubocop-performance/issues/152
            #
            # So here is noop.
          when :begin
            child = lhs.children.first
            "#{lhs.source}.include?(#{rhs.source})" if child&.range_type?
          when :const
            "#{rhs.source}.is_a?(#{lhs.source})"
          end
        end
      end
    end
  end
end
