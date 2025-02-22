# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop remove redundant `keyword_init: true` option in Struct.new.
      # Since Ruby 3.2, Struct instances automatically support keyword initialization by default,
      # making this option unnecessary.
      #
      # @example
      #   # bad
      #   foo = Struct.new(:bar, keyword_init: true)
      #
      #   # good
      #   foo = Struct.new(:bar)
      class RedundantStructKeywordInit < Base
        extend AutoCorrector

        MSG = 'Redundant use of keyword_init: true in Struct.new.'

        def_node_matcher :struct_with_keyword_init?, <<~PATTERN
          (send
            (const nil? :Struct) :new
            ...
            (hash
              (pair
                (sym :keyword_init)
                (true))))
        PATTERN

        def on_send(node)
          return if target_ruby_version < 3.2
          return unless struct_with_keyword_init?(node)

          add_offense(node) do |corrector|
            last_arg = node.arguments.last
            prev_arg = node.arguments[-2]

            start_pos = prev_arg.source_range.end_pos
            end_pos = last_arg.source_range.end_pos

            range = Parser::Source::Range.new(node.source_range.source_buffer, start_pos, end_pos)
            corrector.remove(range)
          end
        end
        alias on_csend on_send
      end
    end
  end
end
