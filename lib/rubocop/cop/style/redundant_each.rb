# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant `each`.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Enumerator`.
      #
      # @example
      #
      #   # bad
      #   array.each.each { |v| do_something(v) }
      #
      #   # good
      #   array.each { |v| do_something(v) }
      #
      #   # bad
      #   array.each.each_with_index { |v, i| do_something(v, i) }
      #
      #   # good
      #   array.each.with_index { |v, i| do_something(v, i) }
      #   array.each_with_index { |v, i| do_something(v, i) }
      #
      #   # bad
      #   array.each.each_with_object { |v, o| do_something(v, o) }
      #
      #   # good
      #   array.each.with_object { |v, o| do_something(v, o) }
      #   array.each_with_object { |v, o| do_something(v, o) }
      #
      class RedundantEach < Base
        extend AutoCorrector

        MSG = 'Remove redundant `each`.'
        MSG_WITH_INDEX = 'Use `with_index` to remove redundant `each`.'
        MSG_WITH_OBJECT = 'Use `with_object` to remove redundant `each`.'

        RESTRICT_ON_SEND = %i[each each_with_index each_with_object].freeze

        def on_send(node)
          return unless (redundant_node = redundant_each_method(node))

          range = range(node)

          add_offense(range, message: message(node)) do |corrector|
            case node.method_name
            when :each
              remove_redundant_each(corrector, range, redundant_node)
            when :each_with_index
              corrector.replace(node.loc.selector, 'with_index')
            when :each_with_object
              corrector.replace(node.loc.selector, 'with_object')
            end
          end
        end
        alias on_csend on_send

        private

        # rubocop:disable-next Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def redundant_each_method(node)
          return if node.last_argument&.block_pass_type?

          if node.method?(:each) && !node.parent&.any_block_type?
            ancestor_node = node.each_ancestor(:call).detect do |ancestor|
              ancestor.receiver == node &&
                (RESTRICT_ON_SEND.include?(ancestor.method_name) || ancestor.method?(:reverse_each))
            end

            return ancestor_node if ancestor_node
          end

          return unless (prev_method = node.children.first)
          return if !prev_method.call_type? || prev_method.parent.any_block_type? ||
                    prev_method.last_argument&.block_pass_type?

          detected = prev_method.method_name.to_s.start_with?('each_') unless node.method?(:each)

          prev_method if detected || prev_method.method?(:reverse_each)
        end

        def range(node)
          return node.selector unless node.method?(:each)

          if receiver_of_dot_call?(node)
            node.selector.join(node.parent.loc.dot)
          else
            node.loc.dot.join(node.selector)
          end
        end

        def message(node)
          case node.method_name
          when :each
            MSG
          when :each_with_index
            MSG_WITH_INDEX
          when :each_with_object
            MSG_WITH_OBJECT
          end
        end

        def remove_redundant_each(corrector, range, redundant_node)
          return unless removable_each?(range)
          return unless (range = with_preceding_line_break(range, redundant_node))

          corrector.remove(range)

          if redundant_node.method?(:each_with_index)
            corrector.replace(redundant_node.loc.selector, 'each.with_index')
          elsif redundant_node.method?(:each_with_object)
            corrector.replace(redundant_node.loc.selector, 'each.with_object')
          end
        end

        def removable_each?(range)
          between = processed_source.tokens_within(range)[1...-1]
          between.empty? || between.map(&:type) == %i[tLPAREN2 tRPAREN]
        end

        # The block of an `each` that starts its line would be left without a call, so the
        # line break goes too, unless there's a comment before it.
        def with_preceding_line_break(range, redundant_node)
          receiver_end = redundant_node.source_range.end
          return range if receiver_end.end_pos >= range.begin_pos

          gap = receiver_end.join(range.begin)
          range.join(gap) if gap.source.strip.empty?
        end

        def receiver_of_dot_call?(node)
          parent = node.parent
          return false unless parent&.call_type?

          parent.receiver.equal?(node) && parent.loc?(:dot)
        end
      end
    end
  end
end
