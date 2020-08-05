# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the case equality operator(===).
      #
      # @example
      #   # bad
      #   Array === something
      #   (1..100) === 7
      #   /something/ === some_string
      #
      #   # good
      #   something.is_a?(Array)
      #   (1..100).include?(7)
      #   some_string =~ /something/
      #
      # @example AllowOnConstant
      #   # Style/CaseEquality:
      #   #   AllowOnConstant: true
      #
      #   # bad
      #   (1..100) === 7
      #   /something/ === some_string
      #
      #   # good
      #   Array === something
      #   (1..100).include?(7)
      #   some_string =~ /something/
      #
      class CaseEquality < Base
        extend AutoCorrector

        MSG = 'Avoid the use of the case equality operator `===`.'

        def_node_matcher :case_equality?, '(send $#const? :=== $_)'

        def on_send(node)
          case_equality?(node) do |lhs, rhs|
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
            "#{rhs.source} =~ #{lhs.source}"
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
