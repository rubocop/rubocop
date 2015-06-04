# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of Time methods without zone.
      #
      # Built on top of Ruby on Rails style guide (https://github.com/bbatsov/rails-style-guide#time)
      # and the article http://danilenko.org/2012/7/6/rails_timezones/ .
      #
      # Two styles are supported for this cop. When EnforcedStyle is 'always'
      # then only use of Time.zone is allowed.
      #
      # When EnforcedStyle is 'acceptable' then it's also allowed
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
      #   # no offense only if style is 'acceptable'
      #   DateTime.strptime(str, "%Y-%m-%d %H:%M %Z").in_time_zone
      #   Time.at(timestamp).in_time_zone
      class TimeZone < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Do not use `%s` without zone. Use `%s` instead.'

        MSG_ACCEPTABLE = 'Do not use `%s` without zone. Use one of %s instead.'

        MSG_LOCALTIME = 'Do not use `Time.localtime` without offset or zone.'

        TIMECLASS = [:Time, :DateTime]

        DANGER_METHODS = [:now, :local, :new, :strftime, :parse, :at]

        ACCEPTED_METHODS = [:in_time_zone, :utc, :getlocal,
                            :iso8601, :jisx0301, :rfc3339,
                            :to_i, :to_f]

        def on_const(node)
          _module, klass = *node

          return unless method_send?(node)

          check_time_node(klass, node.parent) if TIMECLASS.include?(klass)
        end

        private

        def check_time_node(klass, node)
          chain = extract_method_chain(node)
          return if danger_chain?(chain)

          return check_localtime(node) if need_check_localtime?(chain)

          method_name = (chain & DANGER_METHODS).join('.')

          message = build_message(klass, method_name, node)

          add_offense(node, :selector, message)
        end

        def build_message(klass, method_name, node)
          if acceptable?
            format(MSG_ACCEPTABLE,
                   "#{klass}.#{method_name}",
                   acceptable_methods(klass, method_name, node).join(', ')
                  )
          else
            safe_method_name = safe_method(method_name, node)
            format(MSG,
                   "#{klass}.#{method_name}",
                   "#{klass}.zone.#{safe_method_name}"
                  )
          end
        end

        def extract_method_chain(node)
          chain = []
          while !node.nil? && node.send_type?
            chain << extract_method(node)
            node = node.parent
          end
          chain
        end

        def extract_method(node)
          _receiver, method_name, *_args = *node
          method_name
        end

        # checks that parent node of send_type
        # and receiver is the given node
        def method_send?(node)
          return false unless node.parent.send_type?

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
          (chain & DANGER_METHODS).empty? || !(chain & good_methods).empty?
        end

        def need_check_localtime?(chain)
          acceptable? && chain.include?(:localtime)
        end

        def acceptable?
          style == :acceptable
        end

        def good_methods
          style == :always ? [:zone] : [:zone] + ACCEPTED_METHODS
        end

        def acceptable_methods(klass, method_name, node)
          acceptable = [
            "`#{klass}.zone.#{safe_method(method_name, node)}`"
          ]

          ACCEPTED_METHODS.each do |am|
            acceptable << "`#{klass}.#{method_name}.#{am}`"
          end

          acceptable
        end
      end
    end
  end
end
