# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if modifier keywords are preceded by a space.
      class SpaceBeforeModifierKeyword < Cop
        MSG = 'Put a space before the modifier keyword.'

        def on_if(node)
          if modifier?(node)
            kw = node.loc.keyword
            b = kw.begin_pos
            left_of_kw = Parser::Source::Range.new(kw.source_buffer, b - 1, b)
            add_offence(node, left_of_kw) unless left_of_kw.is?(' ')
          end
        end

        alias_method :on_while, :on_if
        alias_method :on_until, :on_if

        private

        def modifier?(node)
          node.loc.respond_to?(:end) && node.loc.end.nil? && !elsif?(node)
        end

        def elsif?(node)
          node.loc.keyword.is?('elsif')
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.insert_before(node.loc.keyword, ' ')
          end
        end
      end
    end
  end
end
