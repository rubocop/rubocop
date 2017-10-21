# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of `DateTime` that should be replaced by
      # `Date` or `Time`.
      #
      # @example
      #
      #   # bad - uses `DateTime` for current time
      #   DateTime.now
      #
      #   # good - uses `Time` for current time
      #   Time.now
      #
      #   # bad - uses `DateTime` for modern date
      #   DateTime.iso8601('2016-06-29')
      #
      #   # good - uses `Date` for modern date
      #   Date.iso8601('2016-06-29')
      #
      #   # good - uses `DateTime` with start argument for historical date
      #   DateTime.iso8601('1751-04-23', Date::ENGLAND)
      class DateTime < Cop
        MSG = 'Prefer Date or Time over DateTime.'.freeze

        def_node_matcher :date_time?, <<-PATTERN
          (send (const {nil? (cbase)} :DateTime) ...)
        PATTERN

        def_node_matcher :historic_date?, <<-PATTERN
          (send _ _ _ (const (const nil? :Date) _))
        PATTERN

        def on_send(node)
          return unless date_time?(node)
          return if historic_date?(node)
          add_offense(node)
        end
      end
    end
  end
end
