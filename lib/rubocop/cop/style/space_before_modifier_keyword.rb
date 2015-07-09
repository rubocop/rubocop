# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Here we check if modifier keywords are preceded by one space.
      class SpaceBeforeModifierKeyword < Cop
        MSG_MISSING = 'Put a space before the modifier keyword.'
        MSG_EXTRA = 'Put only one space before the modifier keyword.'

        def on_if(node)
          return unless modifier?(node)

          kw = node.loc.keyword
          kw_with_space = range_with_surrounding_space(kw, :left)
          space_length = kw_with_space.length - kw.length

          if space_length == 0
            add_offense(kw, kw, MSG_MISSING)
          elsif space_length > 1
            space = kw_with_space.resize(space_length)
            add_offense(space, space, MSG_EXTRA)
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

        def autocorrect(range)
          lambda do |corrector|
            if range.source.start_with?(' ')
              corrector.replace(range, ' ')
            else
              corrector.insert_before(range, ' ')
            end
          end
        end
      end
    end
  end
end
