# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where custom logic on rejection nils from arrays
      # and hashes can be replaced with `{Array,Hash}#{compact,compact!}`.
      #
      # It is marked as unsafe by default because false positives may occur in the
      # nil check of block arguments to the receiver object.
      # For example, `[[1, 2], [3, nil]].reject { |first, second| second.nil? }`
      # and `[[1, 2], [3, nil]].compact` are not compatible. This will work fine
      # when the receiver is a hash object.
      #
      # @example
      #   # bad
      #   array.reject { |e| e.nil? }
      #   array.select { |e| !e.nil? }
      #
      #   # good
      #   array.compact
      #
      #   # bad
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

        # @!method reject_method?(node)
        def_node_matcher :reject_method?, <<~PATTERN
          (block
            (send
              _ ${:reject :reject!})
            $(args ...)
            (send
              $(lvar _) :nil?))
        PATTERN

        # @!method select_method?(node)
        def_node_matcher :select_method?, <<~PATTERN
          (block
            (send
              _ ${:select :select!})
            $(args ...)
            (send
              (send
                $(lvar _) :nil?) :!))
        PATTERN

        def on_send(node)
          block_node = node.parent
          return unless block_node&.block_type?

          return unless (method_name, args, receiver =
                           reject_method?(block_node) || select_method?(block_node))

          return unless args.last.source == receiver.source

          range = offense_range(node, block_node)
          good = good_method_name(method_name)
          message = format(MSG, good: good, bad: range.source)

          add_offense(range, message: message) do |corrector|
            corrector.replace(range, good)
          end
        end

        private

        def good_method_name(method_name)
          if method_name.to_s.end_with?('!')
            'compact!'
          else
            'compact'
          end
        end

        def offense_range(send_node, block_node)
          range_between(send_node.loc.selector.begin_pos, block_node.loc.end.end_pos)
        end
      end
    end
  end
end
