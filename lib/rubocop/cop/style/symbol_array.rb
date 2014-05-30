# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for array literals made up of symbols
      # that are not using the %i() syntax.
      #
      # This check makes sense only on Ruby 2.0+.
      class SymbolArray < Cop
        include ArraySyntax

        MSG = 'Use %i or %I for array of symbols.'

        def on_array(node)
          # %i and %I were introduced in Ruby 2.0
          return if RUBY_VERSION < '2.0.0'
          add_offense(node, :expression) if array_of?(:sym, node)
        end
      end
    end
  end
end
