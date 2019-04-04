# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks Rails model validations for a redundant `allow_nil` when
      # `allow_blank` is present.
      #
      # @example
      #   # bad
      #   validates :x, length: { is: 5 }, allow_nil: true, allow_blank: true
      #
      #   # bad
      #   validates :x, length: { is: 5 }, allow_nil: false, allow_blank: true
      #
      #   # bad
      #   validates :x, length: { is: 5 }, allow_nil: false, allow_blank: false
      #
      #   # good
      #   validates :x, length: { is: 5 }, allow_blank: true
      #
      #   # good
      #   validates :x, length: { is: 5 }, allow_blank: false
      #
      #   # good
      #   # Here, `nil` is valid but `''` is not
      #   validates :x, length: { is: 5 }, allow_nil: true, allow_blank: false
      #
      class RedundantAllowNil < Cop
        include RangeHelp

        MSG_SAME =
          '`allow_nil` is redundant when `allow_blank` has the same value.'
          .freeze
        MSG_ALLOW_NIL_FALSE =
          '`allow_nil: false` is redundant when `allow_blank` is true.'.freeze

        def on_send(node)
          return unless node.method_name == :validates

          allow_nil, allow_blank = find_allow_nil_and_allow_blank(node)
          return unless allow_nil && allow_blank

          allow_nil_val = allow_nil.children.last
          allow_blank_val = allow_blank.children.last

          offense(allow_nil_val, allow_blank_val, allow_nil)
        end

        def autocorrect(node)
          prv_sib = previous_sibling(node)
          nxt_sib = next_sibling(node)

          lambda do |corrector|
            if nxt_sib
              corrector.remove(range_between(node_beg(node), node_beg(nxt_sib)))
            elsif prv_sib
              corrector.remove(range_between(node_end(prv_sib), node_end(node)))
            else
              corrector.remove(node.loc.expression)
            end
          end
        end

        private

        def offense(allow_nil_val, allow_blank_val, allow_nil)
          if allow_nil_val.type == allow_blank_val.type
            add_offense(allow_nil, message: MSG_SAME)
          elsif allow_nil_val.false_type? && allow_blank_val.true_type?
            add_offense(allow_nil, message: MSG_ALLOW_NIL_FALSE)
          end
        end

        def find_allow_nil_and_allow_blank(node)
          allow_nil = nil
          allow_blank = nil

          node.each_descendant do |descendant|
            next unless descendant.pair_type?

            key = descendant.children.first.value

            allow_nil = descendant if key == :allow_nil
            allow_blank = descendant if key == :allow_blank

            break if allow_nil && allow_blank
          end

          [allow_nil, allow_blank]
        end

        def previous_sibling(node)
          node.parent.children[node.sibling_index - 1]
        end

        def next_sibling(node)
          node.parent.children[node.sibling_index + 1]
        end

        def node_beg(node)
          node.loc.expression.begin_pos
        end

        def node_end(node)
          node.loc.expression.end_pos
        end
      end
    end
  end
end
