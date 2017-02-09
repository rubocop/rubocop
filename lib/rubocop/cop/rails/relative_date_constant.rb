# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks whether constant are relative date.
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

        RELATIVE_DATE_METHODS = %i(ago from_now since until).freeze

        def on_casgn(node)
          bad_node = node.descendants.find { |n| bad_method?(n) }
          return unless bad_node

          add_offense(node, :expression, format(MSG, bad_node.method_name))
        end

        private

        def bad_method?(node)
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
