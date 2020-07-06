# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for consistent usage of the `DateTime` class over the
      # `Time` class. This cop is disabled by default since these classes,
      # although highly overlapping, have particularities that make them not
      # replaceable in certain situations when dealing with multiple timezones
      # and/or DST.
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
      #   # good - uses `Time` for modern date
      #   Time.iso8601('2016-06-29')
      #
      #   # good - uses `DateTime` with start argument for historical date
      #   DateTime.iso8601('1751-04-23', Date::ENGLAND)
      #
      # @example AllowCoercion: false (default)
      #
      #   # bad - coerces to `DateTime`
      #   something.to_datetime
      #
      #   # good - coerces to `Time`
      #   something.to_time
      #
      # @example AllowCoercion: true
      #
      #   # good
      #   something.to_datetime
      #
      #   # good
      #   something.to_time
      class DateTime < Cop
        CLASS_MSG = 'Prefer Time over DateTime.'
        COERCION_MSG = 'Do not use #to_datetime.'

        def_node_matcher :date_time?, <<~PATTERN
          (send (const {nil? (cbase)} :DateTime) ...)
        PATTERN

        def_node_matcher :historic_date?, <<~PATTERN
          (send _ _ _ (const (const {nil? (cbase)} :Date) _))
        PATTERN

        def_node_matcher :to_datetime?, <<~PATTERN
          (send _ :to_datetime)
        PATTERN

        def on_send(node)
          return unless date_time?(node) ||
                        (to_datetime?(node) && disallow_coercion?)
          return if historic_date?(node)

          message = to_datetime?(node) ? COERCION_MSG : CLASS_MSG
          add_offense(node, message: message)
        end

        private

        def disallow_coercion?
          !cop_config['AllowCoercion']
        end
      end
    end
  end
end
