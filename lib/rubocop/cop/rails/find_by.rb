# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `where.first` and
      # change them to use `find_by` instead.
      #
      # This cop is disabled if the TargetRailsVersion is set to less than 4.0.
      #
      # @example
      #   # bad
      #   User.where(name: 'Bruce').first
      #   User.where(name: 'Bruce').take
      #
      #   # good
      #   User.find_by(name: 'Bruce')
      class FindBy < Cop
        extend TargetRailsVersion

        MSG = 'Use `find_by` instead of `where.%s`.'.freeze
        TARGET_SELECTORS = %i[first take].freeze

        def_node_matcher :where_first?, <<-PATTERN
          (send (send _ :where ...) {:first :take})
        PATTERN

        minimum_target_rails_version 4.0

        def on_send(node)
          return unless where_first?(node)

          range = range_between(node.receiver.loc.selector.begin_pos,
                                node.loc.selector.end_pos)

          add_offense(node, location: range,
                            message: format(MSG, node.method_name))
        end

        def autocorrect(node)
          # Don't autocorrect where(...).first, because it can return different
          # results from find_by. (They order records differently, so the
          # 'first' record can be different.)
          return if node.method?(:first)

          where_loc = node.receiver.loc.selector
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
