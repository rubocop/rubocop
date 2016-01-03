# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of the `then` keyword in multi-line if statements.
      #
      # @example This is considered bad practice:
      #
      #   if cond then
      #   end
      #
      # @example If statements can contain `then` on the same line:
      #
      #   if cond then a
      #   elsif cond then b
      #   end
      class MultilineIfThen < Cop
        include IfNode
        include OnNormalIfUnless

        def on_normal_if_unless(node)
          return unless node.loc.begin
          return unless node.loc.begin.source_line =~ /then\s*(#.*)?$/
          add_offense(node, :begin)
        end

        def message(node)
          "Do not use `then` for multi-line `#{node.loc.keyword.source}`."
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(range_with_surrounding_space(node.loc.begin,
                                                          :left))
          end
        end
      end
    end
  end
end
