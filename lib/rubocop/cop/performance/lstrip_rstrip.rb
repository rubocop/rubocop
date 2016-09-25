# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `lstrip.rstrip` can be replaced by
      # `strip`.
      #
      # @example
      #   @bad
      #   'abc'.lstrip.rstrip
      #   'abc'.rstrip.lstrip
      #
      #   @good
      #   'abc'.strip
      class LstripRstrip < Cop
        MSG = 'Use `strip` instead of `%s.%s`.'.freeze

        def_node_matcher :lstrip_rstrip, <<-END
          {(send $(send _ $:rstrip) $:lstrip)
           (send $(send _ $:lstrip) $:rstrip)}
        END

        def on_send(node)
          lstrip_rstrip(node) do |first_send, method_one, method_two|
            range = range_between(first_send.loc.selector.begin_pos,
                                  node.source_range.end_pos)
            add_offense(node, range, format(MSG, method_one, method_two))
          end
        end

        def autocorrect(node)
          first_send, = *node
          range = range_between(first_send.loc.selector.begin_pos,
                                node.source_range.end_pos)
          ->(corrector) { corrector.replace(range, 'strip') }
        end
      end
    end
  end
end
