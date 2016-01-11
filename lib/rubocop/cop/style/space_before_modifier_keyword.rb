# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Here we check if modifier keywords are preceded by a space.
      class SpaceBeforeModifierKeyword < Cop
        MSG = 'Put a space before the modifier keyword.'.freeze

        def on_if(node)
          return unless modifier?(node)

          kw = node.loc.keyword
          b = kw.begin_pos
          left_of_kw = Parser::Source::Range.new(kw.source_buffer, b - 1, b)
          add_offense(node, left_of_kw) unless left_of_kw.is?(' ')
        end
        alias on_while on_if
        alias on_until on_if

        private

        def modifier?(node)
          node.loc.respond_to?(:end) && node.loc.end.nil? && !elsif?(node)
        end

        def elsif?(node)
          node.loc.keyword.is?('elsif')
        end

        def autocorrect(node)
          ->(corrector) { corrector.insert_before(node.loc.keyword, ' ') }
        end
      end
    end
  end
end
