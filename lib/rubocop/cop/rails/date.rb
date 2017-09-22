# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the correct use of Date methods,
      # such as Date.today, Date.current etc.
      #
      # Using Date.today is dangerous, because it doesn't know anything about
      # Rails time zone. You must use Time.zone.today instead.
      #
      # The cop also reports warnings when you are using 'to_time' method,
      # because it doesn't know about Rails time zone either.
      #
      # Two styles are supported for this cop. When EnforcedStyle is 'strict'
      # then the Date methods (today, current, yesterday, tomorrow)
      # are prohibited and the usage of both 'to_time'
      # and 'to_time_in_current_zone' is reported as warning.
      #
      # When EnforcedStyle is 'flexible' then only 'Date.today' is prohibited
      # and only 'to_time' is reported as warning.
      #
      # @example
      #   # no offense
      #   Time.zone.today
      #   Time.zone.today - 1.day
      #
      #   # flexible
      #   Date.current
      #   Date.yesterday
      #
      #   # always reports offense
      #   Date.today
      #   date.to_time
      #
      #   # reports offense only when style is 'strict'
      #   date.to_time_in_current_zone
      class Date < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Do not use `%s` without zone. Use `%s` instead.'.freeze

        MSG_SEND = 'Do not use `%s` on Date objects, because they ' \
                   'know nothing about the time zone in use.'.freeze

        BAD_DAYS = %i[today current yesterday tomorrow].freeze

        def on_const(node)
          mod, klass = *node.children
          # we should only check core Date class (`Date` or `::Date`)
          return unless (mod.nil? || mod.cbase_type?) && method_send?(node)

          check_date_node(node.parent) if klass == :Date
        end

        def on_send(node)
          return unless node.receiver && bad_methods.include?(node.method_name)

          return if safe_chain?(node) || safe_to_time?(node)

          add_offense(node, :selector, format(MSG_SEND, node.method_name))
        end

        private

        def check_date_node(node)
          chain = extract_method_chain(node)

          return if (chain & bad_days).empty?

          method_name = (chain & bad_days).join('.')

          add_offense(node, :selector,
                      format(MSG,
                             "Date.#{method_name}",
                             "Time.zone.#{method_name}"))
        end

        def extract_method_chain(node)
          [node, *node.each_ancestor(:send)].map(&:method_name)
        end

        # checks that parent node of send_type
        # and receiver is the given node
        def method_send?(node)
          return false unless node.parent && node.parent.send_type?

          node.parent.receiver == node
        end

        def safe_chain?(node)
          chain = extract_method_chain(node)

          (chain & bad_methods).empty? || !(chain & good_methods).empty?
        end

        def safe_to_time?(node)
          return unless node.method?(:to_time)

          if node.receiver.str_type?
            zone_regexp = /([+-][\d:]+|\dZ)\z/

            node.receiver.str_content.match(zone_regexp)
          else
            node.arguments.one?
          end
        end

        def good_days
          style == :strict ? [] : %i[current yesterday tomorrow]
        end

        def bad_days
          BAD_DAYS - good_days
        end

        def bad_methods
          style == :strict ? %i[to_time to_time_in_current_zone] : [:to_time]
        end

        def good_methods
          style == :strict ? [] : TimeZone::ACCEPTED_METHODS
        end
      end
    end
  end
end
