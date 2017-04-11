# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks whether constant value isn't relative date.
      # Because the relative date will be evaluated only once.
      #
      # @example
      #   # bad
      #   class SomeClass
      #     EXPIRED_AT = 1.week.since
      #   end
      #
      #   # good
      #   class SomeClass
      #     def self.expired_at
      #       1.week.since
      #     end
      #   end
      class RelativeDateConstant < Cop
        MSG = 'Do not assign %s to constants as it will be evaluated only ' \
              'once.'.freeze

        RELATIVE_DATE_METHODS = %i[ago from_now since until].freeze

        def on_casgn(node)
          _scope, _constant, rhs = *node

          # rhs would be nil in a or_asgn node
          return unless rhs

          check_node(rhs)
        end

        def on_masgn(node)
          lhs, rhs = *node

          return unless rhs && rhs.array_type?

          lhs.children.zip(rhs.children).each do |(name, value)|
            check_node(value) if name.casgn_type?
          end
        end

        def on_or_asgn(node)
          lhs, rhs = *node

          return unless lhs.casgn_type?

          check_node(rhs)
        end

        private

        def check_node(node)
          return unless node.irange_type? ||
                        node.erange_type? ||
                        node.send_type?

          # for range nodes we need to check both their boundaries
          nodes = node.send_type? ? [node] : node.children

          nodes.each do |n|
            if relative_date_method?(n)
              add_offense(node.parent, :expression, format(MSG, n.method_name))
            end
          end
        end

        def relative_date_method?(node)
          node.send_type? &&
            RELATIVE_DATE_METHODS.include?(node.method_name) &&
            node.method_args.empty?
        end

        def autocorrect(node)
          _scope, const_name, value = *node
          indent = ' ' * node.loc.column
          new_code = ["def self.#{const_name.downcase}",
                      "#{indent}#{value.source}",
                      'end'].join("\n#{indent}")
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end
      end
    end
  end
end
