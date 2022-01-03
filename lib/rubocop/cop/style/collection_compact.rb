# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where custom logic on rejection nils from arrays
      # and hashes can be replaced with `{Array,Hash}#{compact,compact!}`.
      #
      # @safety
      #   It is unsafe by default because false positives may occur in the
      #   `nil` check of block arguments to the receiver object.
      #
      #   For example, `[[1, 2], [3, nil]].reject { |first, second| second.nil? }`
      #   and `[[1, 2], [3, nil]].compact` are not compatible. This will work fine
      #   when the receiver is a hash object.
      #
      # @example
      #   # bad
      #   array.reject(&:nil?)
      #   array.reject { |e| e.nil? }
      #   array.select { |e| !e.nil? }
      #
      #   # good
      #   array.compact
      #
      #   # bad
      #   hash.reject!(&:nil?)
      #   hash.reject! { |k, v| v.nil? }
      #   hash.select! { |k, v| !v.nil? }
      #
      #   # good
      #   hash.compact!
      #
      class CollectionCompact < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `%<good>s` instead of `%<bad>s`.'

        RESTRICT_ON_SEND = %i[reject reject! select select!].freeze

        # @!method reject_method_with_block_pass?(node)
        def_node_matcher :reject_method_with_block_pass?, <<~PATTERN
          (send !nil? {:reject :reject!}
            (block_pass
              (sym :nil?)))
        PATTERN

        # @!method reject_method?(node)
        def_node_matcher :reject_method?, <<~PATTERN
          (block
            (send
              !nil? {:reject :reject!})
            $(args ...)
            (send
              $(lvar _) :nil?))
        PATTERN

        # @!method select_method?(node)
        def_node_matcher :select_method?, <<~PATTERN
          (block
            (send
              !nil? {:select :select!})
            $(args ...)
            (send
              (send
                $(lvar _) :nil?) :!))
        PATTERN

        def on_send(node)
          return unless (range = offense_range(node))

          good = good_method_name(node.method_name)
          message = format(MSG, good: good, bad: range.source)

          add_offense(range, message: message) { |corrector| corrector.replace(range, good) }
        end

        private

        def offense_range(node)
          if reject_method_with_block_pass?(node)
            range(node, node)
          else
            block_node = node.parent

            return unless block_node&.block_type?
            unless (args, receiver = reject_method?(block_node) || select_method?(block_node))
              return
            end
            return unless args.last.source == receiver.source

            range(node, block_node)
          end
        end

        def good_method_name(method_name)
          if method_name.to_s.end_with?('!')
            'compact!'
          else
            'compact'
          end
        end

        def range(begin_pos_node, end_pos_node)
          range_between(begin_pos_node.loc.selector.begin_pos, end_pos_node.loc.end.end_pos)
        end
      end
    end
  end
end
