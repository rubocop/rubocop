# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for .joins("LEFT JOIN ...") and
      # proposes to use the .left_join("...") method introduced in Rails 5.0.
      #
      # @example
      #  # bad
      #  User.joins('LEFT JOIN emails ON user.id = emails.user_id')
      #
      #  # good
      #  User.left_joins(:emails)
      #
      class LeftJoin < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        def on_send(node)
          return unless node.method?(:joins) && include_left_join?(node)

          prefer  = ".left_join(:#{join_model(node)})".freeze
          current = ".joins('#{join_full_query(node)}')".freeze

          add_offense(node,
                      message: format(MSG, prefer: prefer, current: current),
                      location: :selector,
                      severity: :warning)
        end

        private

        def include_left_join?(node)
          join_query_phrase(node).downcase == "left join"
        end

        def join_full_query(node)
          node.arguments.first.children.first
        end

        def join_model(node)
          join_full_query(node).split[2]
        end

        def join_query_phrase(node)
          query = join_full_query(node).split

          "#{query[0]} #{query[1]}"
        end
      end
    end
  end
end
