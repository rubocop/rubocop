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
        include RangeHelp

        MSG = 'Do not assign %<method_name>s to constants as it ' \
              'will be evaluated only once.'

        def on_casgn(node)
          relative_date_assignment?(node) do |method_name|
            add_offense(node, message: format(MSG, method_name: method_name))
          end
        end

        def on_masgn(node)
          lhs, rhs = *node

          return unless rhs&.array_type?

          lhs.children.zip(rhs.children).each do |(name, value)|
            next unless name.casgn_type?

            relative_date?(value) do |method_name|
              add_offense(node,
                          location: range_between(name.loc.expression.begin_pos,
                                                  value.loc.expression.end_pos),
                          message: format(MSG, method_name: method_name))
            end
          end
        end

        def on_or_asgn(node)
          relative_date_or_assignment?(node) do |method_name|
            add_offense(node, message: format(MSG, method_name: method_name))
          end
        end

        def autocorrect(node)
          return unless node.casgn_type?

          scope, const_name, value = *node
          return unless scope.nil?

          indent = ' ' * node.loc.column
          new_code = ["def self.#{const_name.downcase}",
                      "#{indent}#{value.source}",
                      'end'].join("\n#{indent}")
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end

        private

        def_node_matcher :relative_date_assignment?, <<-PATTERN
          {
            (casgn _ _ (send _ ${:since :from_now :after :ago :until :before}))
            (casgn _ _ ({erange irange} _ (send _ ${:since :from_now :after :ago :until :before})))
            (casgn _ _ ({erange irange} (send _ ${:since :from_now :after :ago :until :before}) _))
          }
        PATTERN

        def_node_matcher :relative_date_or_assignment?, <<-PATTERN
          (:or_asgn (casgn _ _) (send _ ${:since :from_now :after :ago :until :before}))
        PATTERN

        def_node_matcher :relative_date?, <<-PATTERN
          {
            ({erange irange} _ (send _ ${:since :from_now :after :ago :until :before}))
            ({erange irange} (send _ ${:since :from_now :after :ago :until :before}) _)
            (send _ ${:since :from_now :after :ago :until :before})
          }
        PATTERN
      end
    end
  end
end
