# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for nested percent literals.
      #
      # @example
      #
      #   # bad
      #
      #   # The percent literal for nested_attributes is parsed as four tokens,
      #   # yielding the array [:name, :content, :"%i[incorrectly", :"nested]"].
      #   attributes = {
      #     valid_attributes: %i[name content],
      #     nested_attributes: %i[name content %i[incorrectly nested]]
      #   }
      class NestedPercentLiteral < Cop
        include PercentLiteral

        MSG = 'Within percent literals, nested percent literals do not ' \
          'function and may be unwanted in the result.'.freeze

        # The array of regular expressions representing percent literals that,
        # if found within a percent literal expression, will cause a
        # NestedPercentLiteral violation to be emitted.
        REGEXES = PercentLiteral::PERCENT_LITERAL_TYPES.map do |percent_literal|
          /\A#{percent_literal}\W/
        end.freeze

        def on_array(node)
          process(node, *PercentLiteral::PERCENT_LITERAL_TYPES)
        end

        def on_percent_literal(node)
          add_offense(node) if contains_percent_literals?(node)
        end

        private

        def str_content(node)
          if node.str_type?
            node.children[0]
          else
            node.children.map { |c| str_content(c) }.join
          end
        end

        def contains_percent_literals?(node)
          node.each_child_node.any? do |child|
            literal = child.children.first.to_s.scrub
            REGEXES.any? { |regex| literal.match(regex) }
          end
        end
      end
    end
  end
end
