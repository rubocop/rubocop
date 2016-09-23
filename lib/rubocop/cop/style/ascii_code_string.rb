# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for legacy ascii code strings.
      #
      # In Ruby < 1.9, this would return the ascii code of the character.
      #
      # @example
      #   # bad
      #   ?a
      #   ?c
      #
      #   # good
      #   'a'
      #   "c"
      class AsciiCodeString < Cop
        MSG = 'Do not use legacy ascii code strings.'.freeze

        def on_str(node)
          if node.loc.respond_to?(:begin) && node.loc.begin &&
             node.loc.begin.is?('?')
            add_offense(node, :expression)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.begin, "'")
            corrector.insert_after(node.loc.expression, "'")
          end
        end
      end
    end
  end
end
