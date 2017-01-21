# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of Time methods without zone.
      #
      # Built on top of Ruby on Rails style guide (https://github.com/bbatsov/rails-style-guide#time)
      # and the article http://danilenko.org/2012/7/6/rails_timezones/ .
      #
      # Two styles are supported for this cop. When EnforcedStyle is 'strict'
      # then only use of Time.zone is allowed.
      #
      # When EnforcedStyle is 'flexible' then it's also allowed
      # to use Time.in_time_zone.
      #
      # @example
      #   # always offense
      #   Time.now
      #   Time.parse('2015-03-02 19:05:37')
      #
      #   # no offense
      #   Time.zone.now
      #   Time.zone.parse('2015-03-02 19:05:37')
      #
      #   # no offense only if style is 'flexible'
      #   Time.current
      #   DateTime.strptime(str, "%Y-%m-%d %H:%M %Z").in_time_zone
      #   Time.at(timestamp).in_time_zone
      class TimeZone < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Do not use `%s` without zone. Use `%s` instead.'.freeze

        MSG_ACCEPTABLE = 'Do not use `%s` without zone. ' \
                         'Use one of %s instead.'.freeze

        MSG_LOCALTIME = 'Do not use `Time.localtime` without ' \
                        'offset or zone.'.freeze

        MSG_CURRENT = 'Do not use `%s`. Use `Time.zone.now` instead.'.freeze

        TIMECLASS = [:Time, :DateTime].freeze

        DANGEROUS_METHODS = [:now, :local, :new, :strftime,
                             :parse, :at, :current].freeze

        ACCEPTED_METHODS = [:in_time_zone, :utc, :getlocal,
                            :iso8601, :jisx0301, :rfc3339,
                            :to_i, :to_f].freeze

        def on_const(node)
          mod, klass = *node
          # we should only check core class
          # (`DateTime`/`Time` or `::Date`/`::DateTime`)
          return unless (mod.nil? || mod.cbase_type?) && method_send?(node)

          check_time_node(klass, node.parent) if TIMECLASS.include?(klass)
        end

        private

        def check_time_node(klass, node)
          chain = extract_method_chain(node)
          return if danger_chain?(chain)

          return check_localtime(node) if need_check_localtime?(chain)

          method_name = (chain & DANGEROUS_METHODS).join('.')

          return if offset_provided?(node)

          message = build_message(klass, method_name, node)

          add_offense(node, :selector, message)
        end

        def build_message(klass, method_name, node)
          if acceptable?
            format(MSG_ACCEPTABLE,
                   "#{klass}.#{method_name}",
                   acceptable_methods(klass, method_name, node).join(', '))
          elsif method_name == 'current'
            format(MSG_CURRENT,
                   "#{klass}.#{method_name}")
          else
            safe_method_name = safe_method(method_name, node)
            format(MSG,
                   "#{klass}.#{method_name}",
                   "Time.zone.#{safe_method_name}")
          end
        end

        def extract_method_chain(node)
          chain = []
          while !node.nil? && node.send_type?
            chain << extract_method(node) if method_from_time_class?(node)
            node = node.parent
          end
          chain
        end

        def extract_method(node)
          _receiver, method_name, *_args = *node
          method_name
        end

        # Only add the method to the chain if the method being
        # called is part of the time class.
        def method_from_time_class?(node)
          receiver, method_name, *_args = *node
          if (receiver.is_a? RuboCop::AST::Node) && !receiver.cbase_type?
            method_from_time_class?(receiver)
          else
            TIMECLASS.include? method_name
          end
        end

        # checks that parent node of send_type
        # and receiver is the given node
        def method_send?(node)
          return false unless node.parent && node.parent.send_type?

          receiver, _method_name, *_args = *node.parent

          receiver == node
        end

        def safe_method(method_name, node)
          _receiver, _method_name, *args = *node
          return method_name unless method_name == 'new'

          if args.empty?
            'now'
          else
            'local'
          end
        end

        def check_localtime(node)
          selector_node = node
          while !node.nil? && node.send_type?
            break if extract_method(node) == :localtime
            node = node.parent
          end
          _receiver, _method, args = *node

          add_offense(selector_node, :selector, MSG_LOCALTIME) if args.nil?
        end

        def danger_chain?(chain)
          (chain & DANGEROUS_METHODS).empty? || !(chain & good_methods).empty?
        end

        def need_check_localtime?(chain)
          acceptable? && chain.include?(:localtime)
        end

        def acceptable?
          style == :flexible
        end

        def good_methods
          if style == :strict
            [:zone, :zone_default]
          else
            [:zone, :zone_default, :current] + ACCEPTED_METHODS
          end
        end

        def acceptable_methods(klass, method_name, node)
          acceptable = [
            "`Time.zone.#{safe_method(method_name, node)}`",
            "`#{klass}.current`"
          ]

          ACCEPTED_METHODS.each do |am|
            acceptable << "`#{klass}.#{method_name}.#{am}`"
          end

          acceptable
        end

        # Time.new can be called with a time zone offset
        # When it is, that should be considered safe
        # Example:
        # Time.new(1988, 3, 15, 3, 0, 0, "-05:00")
        def offset_provided?(node)
          _, _, *args = *node
          args.length >= 7
        end
      end
    end
  end
end
