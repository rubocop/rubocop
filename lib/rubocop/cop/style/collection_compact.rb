# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where custom logic on rejection nils from arrays
      # and hashes can be replaced with `{Array,Hash}#{compact,compact!}`.
      #
      # @safety
      #   It is unsafe by default because false positives may occur in the
      #   `nil` check of block arguments to the receiver object. Additionally,
      #   we can't know the type of the receiver object for sure, which may
      #   result in false positives as well.
      #
      #   For example, `[[1, 2], [3, nil]].reject { |first, second| second.nil? }`
      #   and `[[1, 2], [3, nil]].compact` are not compatible. This will work fine
      #   when the receiver is a hash object.
      #
      # @example
      #   # bad
      #   array.reject(&:nil?)
      #   array.delete_if(&:nil?)
      #   array.reject { |e| e.nil? }
      #   array.delete_if { |e| e.nil? }
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
      # @example AllowedReceivers: ['params']
      #   # good
      #   params.reject(&:nil?)
      #
      class CollectionCompact < Base
        include AllowedReceivers
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        MSG = 'Use `%<good>s` instead of `%<bad>s`.'
        RESTRICT_ON_SEND = %i[reject delete_if reject! select select!].freeze
        TO_ENUM_METHODS = %i[to_enum lazy].freeze

        minimum_target_ruby_version 2.4

        # @!method reject_method_with_block_pass?(node)
        def_node_matcher :reject_method_with_block_pass?, <<~PATTERN
          (send !nil? {:reject :delete_if :reject!}
            (block_pass
              (sym :nil?)))
        PATTERN

        # @!method reject_method?(node)
        def_node_matcher :reject_method?, <<~PATTERN
          (block
            (send
              !nil? {:reject :delete_if :reject!})
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
          return if allowed_receiver?(node.receiver)
          if (target_ruby_version <= 3.0 || node.method?(:delete_if)) && to_enum_method?(node)
            return
          end

          good = good_method_name(node)
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

        def to_enum_method?(node)
          return false unless node.receiver.send_type?

          TO_ENUM_METHODS.include?(node.receiver.method_name)
        end

        def good_method_name(node)
          if node.bang_method?
            'compact!'
          else
            'compact'
          end
        end

        def range(begin_pos_node, end_pos_node)
          range_between(begin_pos_node.loc.selector.begin_pos, end_pos_node.source_range.end_pos)
        end
      end
    end
  end
end
