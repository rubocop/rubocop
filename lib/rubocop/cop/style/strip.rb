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
      class Strip < Cop
        include RangeHelp

        MSG = 'Use `strip` instead of `%<methods>s`.'

        def_node_matcher :lstrip_rstrip, <<-PATTERN
          {(send $(send _ $:rstrip) $:lstrip)
           (send $(send _ $:lstrip) $:rstrip)}
        PATTERN

        def on_send(node)
          lstrip_rstrip(node) do |first_send, method_one, method_two|
            range = range_between(first_send.loc.selector.begin_pos,
                                  node.source_range.end_pos)
            add_offense(node,
                        location: range,
                        message: format(MSG,
                                        methods: "#{method_one}.#{method_two}"))
          end
        end

        def autocorrect(node)
          range = range_between(node.receiver.loc.selector.begin_pos,
                                node.source_range.end_pos)

          ->(corrector) { corrector.replace(range, 'strip') }
        end
      end
    end
  end
end
