# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop identifies places where `lstrip.rstrip` can be replaced by
      # `strip`.
      #
      # @example
      #   # bad
      #   'abc'.lstrip.rstrip
      #   'abc'.rstrip.lstrip
      #
      #   # good
      #   'abc'.strip
      class Strip < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `strip` instead of `%<methods>s`.'
        RESTRICT_ON_SEND = %i[lstrip rstrip].freeze

        def_node_matcher :lstrip_rstrip, <<~PATTERN
          {(send $(send _ $:rstrip) $:lstrip)
           (send $(send _ $:lstrip) $:rstrip)}
        PATTERN

        def on_send(node)
          lstrip_rstrip(node) do |first_send, method_one, method_two|
            range = range_between(first_send.loc.selector.begin_pos, node.source_range.end_pos)
            message = format(MSG, methods: "#{method_one}.#{method_two}")

            add_offense(range, message: message) do |corrector|
              corrector.replace(range, 'strip')
            end
          end
        end
      end
    end
  end
end
