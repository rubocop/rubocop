# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `where.first` and
      # change them to use `find_by` instead.
      #
      # @example
      #   # bad
      #   User.where(name: 'Bruce').first
      #   User.where(name: 'Bruce').take
      #
      #   # good
      #   User.find_by(name: 'Bruce')
      class FindBy < Cop
        MSG = 'Use `find_by` instead of `where.%s`.'.freeze
        TARGET_SELECTORS = [:first, :take].freeze

        def_node_matcher :where_first, <<-PATTERN
          (send $(send _ :where ...) ${:first :take})
        PATTERN

        def on_send(node)
          return unless (recv_and_method = where_first(node))
          receiver, second_method = *recv_and_method

          range = range_between(receiver.loc.selector.begin_pos,
                                node.loc.selector.end_pos)

          add_offense(node, range, format(MSG, second_method))
        end

        def autocorrect(node)
          receiver, second_method = where_first(node)
          # Don't autocorrect where(...).first, because it can return different
          # results from find_by. (They order records differently, so the
          # 'first' record can be different.)
          return if second_method == :first

          where_loc = receiver.loc.selector
          first_loc = range_between(node.loc.dot.begin_pos,
                                    node.loc.selector.end_pos)

          lambda do |corrector|
            corrector.replace(where_loc, 'find_by')
            corrector.replace(first_loc, '')
          end
        end
      end
    end
  end
end
