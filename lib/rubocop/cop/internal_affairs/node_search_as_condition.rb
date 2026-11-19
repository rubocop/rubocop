# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for node searches that are used as a condition. A search that
      # is defined with `def_node_search` and a name that does not end in `?`
      # returns an enumerator when it is called without a block, and an
      # enumerator is truthy even if nothing matches.
      #
      # Only the searches that are defined in the same file are known.
      #
      # @example
      #   def_node_search :assignments, '(lvasgn ...)'
      #
      #   # bad
      #   return unless assignments(node)
      #
      #   # bad
      #   assignments(node) && something
      #
      #   # good
      #   return unless assignments(node).any?
      #
      #   # good
      #   assignments(node) { |assignment| do_something(assignment) }
      #
      #   # good
      #   def_node_search :assignments?, '(lvasgn ...)'
      #
      #   return unless assignments?(node)
      #
      class NodeSearchAsCondition < Base
        MSG = '`%<name>s` returns an enumerator, which is always truthy. ' \
              'Use `%<name>s(...).any?`, or define the search with a name that ends in `?`.'

        # @!method node_search_name(node)
        def_node_matcher :node_search_name, <<~PATTERN
          (send nil? :def_node_search (sym $_) ...)
        PATTERN

        def on_new_investigation
          @node_searches = nil
        end

        def on_send(node) # rubocop:disable InternalAffairs/OnSendWithoutOnCSend -- a search is called without a receiver
          return unless node_searches.include?(node.method_name)
          return if node.receiver || node.block_literal? || node.block_argument?
          return unless condition?(node)

          add_offense(node, message: format(MSG, name: node.method_name))
        end

        private

        def node_searches
          @node_searches ||= processed_source.ast.each_node(:send).filter_map do |node|
            name = node_search_name(node)

            name unless name.nil? || name.end_with?('?')
          end.to_set
        end

        def condition?(node)
          parent = node.parent
          return false unless parent

          if parent.type?(:and, :or)
            parent.lhs.equal?(node)
          elsif parent.type?(:if, :while, :until)
            parent.condition.equal?(node)
          else
            parent.send_type? && parent.method?(:!)
          end
        end
      end
    end
  end
end
