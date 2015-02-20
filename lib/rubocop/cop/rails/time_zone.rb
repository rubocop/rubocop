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

        TIMECLASS = [:Time, :DateTime]

        DANGER_METHODS = [:now, :local, :new, :strptime, :parse, :at]

        def on_const(node)
          _module, klass = *node

          return unless method_send?(node)

          check_time_node(klass, node.parent) if TIMECLASS.include?(klass)
        end

        private

        def check_time_node(klass, node)
          chain = extract_method_chain(node)
          return if (chain & DANGER_METHODS).empty? ||
                    !(chain & good_methods).empty?

          method_name = *(chain & DANGER_METHODS)

          add_offense(node, :selector,
                      format(MSG,
                             "#{klass}.#{method_name}",
                             "#Time.zone.#{method_name}")
                     )
        end

        def extract_method_chain(node)
          chain = []
          p = node
          while !p.nil? && p.send_type?
            chain << extract_method(p)
            p = p.parent
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

        def good_methods
          style == :always ? [:zone] : [:zone, :in_time_zone]
        end
      end
    end
  end
end
