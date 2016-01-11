# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking hash nodes.
    module HashNode
      def any_pairs_on_the_same_line?(node)
        node.children.butfirst.any? do |pair|
          !Util.begins_its_line?(pair.loc.expression)
        end
      end
    end
  end
end
