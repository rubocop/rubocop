# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for numbered parameters.
      #
      # It can either restrict the use of numbered parameters to
      # single-lined blocks, or disallow completely numbered parameters.
      #
      # @example EnforcedStyle: allow_single_line (default)
      #   # bad
      #   collection.each do
      #     puts _1
      #   end
      #
      #   # good
      #   collection.each { puts _1 }
      #   collection.foo
      #             .each { puts _1 }
      #   collection.foo.each { puts _1 }
      #
      # @example EnforcedStyle: allow_exact_single_line
      #   # bad
      #   collection.each do
      #     puts _1
      #   end
      #   collection.foo
      #             .each { puts _1 }
      #
      #   # good
      #   collection.each { puts _1 }
      #   collection.foo.each { puts _1 }
      #
      # @example EnforcedStyle: disallow
      #   # bad
      #   collection.each { puts _1 }
      #
      #   # good
      #   collection.each { |item| puts item }
      #
      class NumberedParameters < Base
        include ConfigurableEnforcedStyle
        extend TargetRubyVersion

        MSG_DISALLOW = 'Avoid using numbered parameters.'
        MSG_MULTI_LINE = 'Avoid using numbered parameters for multi-line blocks.'

        minimum_target_ruby_version 2.7

        def on_numblock(node)
          case style
          when :allow_single_line
            return if node.single_line?

            add_offense(node, message: MSG_MULTI_LINE)
          when :allow_exact_single_line
            return if same_line?(node.source_range.begin, node.source_range.end)

            add_offense(node, message: MSG_MULTI_LINE)
          when :disallow
            add_offense(node, message: MSG_DISALLOW)
          end
        end
      end
    end
  end
end
