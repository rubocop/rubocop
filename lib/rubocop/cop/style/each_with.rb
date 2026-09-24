# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `each_with_index` and `each_with_object` that can be
      # replaced with `each.with_index` and `each.with_object`.
      #
      # @example
      #   # bad
      #   array.each_with_index { |v, i| do_something(v, i) }
      #
      #   # good
      #   array.each.with_index { |v, i| do_something(v, i) }
      #
      #   # bad
      #   array.each_with_object([]) { |v, o| do_something(v, o) }
      #
      #   # good
      #   array.each.with_object([]) { |v, o| do_something(v, o) }
      #
      class EachWith < Base
        extend AutoCorrector
        include RangeHelp

        MSG_WITH_INDEX = 'Use `each.with_index` instead of `each_with_index`.'
        MSG_WITH_OBJECT = 'Use `each.with_object` instead of `each_with_object`.'

        RESTRICT_ON_SEND = %i[each_with_index each_with_object].freeze

        def on_send(node)
          return unless target_method?(node)

          message = node.method?(:each_with_index) ? MSG_WITH_INDEX : MSG_WITH_OBJECT
          range = offense_range(node)

          add_offense(range, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send

        private

        def target_method?(node)
          node.method?(:each_with_index) || node.method?(:each_with_object)
        end

        def offense_range(node)
          range = node.loc.selector
          range = range.join(node.source_range.end) if node.arguments.any?
          range
        end

        def autocorrect(corrector, node)
          method_suffix = if node.method?(:each_with_index)
                            'with_index'
                          else
                            'with_object'
                          end

          range_to_replace = node.loc.selector
          replacement = "each.#{method_suffix}"

          corrector.replace(range_to_replace, replacement)
        end
      end
    end
  end
end
