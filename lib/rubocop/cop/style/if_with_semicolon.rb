# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of semicolon in if statements.
      class IfWithSemicolon < Cop
        include OnNormalIfUnless

        MSG = 'Do not use if x; Use the ternary operator instead.'.freeze

        def on_normal_if_unless(node)
          beginning = node.loc.begin
          return unless beginning && beginning.is?(';')
          add_offense(node, :expression, MSG)
        end
      end
    end
  end
end
