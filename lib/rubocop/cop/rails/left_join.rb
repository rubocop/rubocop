# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for both .joins("LEFT JOIN ...") and
      # .joins("LEFT OUTER JOIN ...").
      # It proposes to use either the .left_joins("...") method
      # or the .left_outer_joins("...") one accordingly.
      # These methods were introduced in Rails 5.0.
      #
      # @example
      #  # bad
      #  User.joins('LEFT JOIN emails ON user.id = emails.user_id')
      #
      #  # good
      #  User.left_joins(:emails)
      #
      #
      #  # bad
      #  User.joins('LEFT OUTER JOIN emails ON user.id = emails.user_id')
      #
      #  # good
      #  User.left_outer_joins(:emails)
      #
      class LeftJoin < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        PREFERRABLE_QUERIES = {
          'left join'       => '.left_joins(:model)',
          'left outer join' => '.left_outer_joins(:model)'
        }.freeze

        def_node_matcher :joins?, <<-PATTERN
          (send _ :joins #left_join_from_query ...)
        PATTERN

        def on_send(node)
          return unless joins?(node)

          query   = left_join_from_query(node)
          current = ".joins('#{query} ...')"
          prefer  = PREFERRABLE_QUERIES[query]
          message = format(MSG, prefer: prefer, current: current)

          add_offense(node, message: message, location: :selector)
        end

        private

        WATCHABLE_QUERIES = ['left join', 'left outer join'].freeze

        def left_join_from_query(node)
          node_query = node.source.downcase

          WATCHABLE_QUERIES.each do |watchable_query|
            return watchable_query if node_query.include?(watchable_query)
          end

          false
        end
      end
    end
  end
end
