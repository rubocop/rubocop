# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for array literals made up of symbols
      # that are not using the %i() syntax.
      #
      # This check makes sense only on Ruby 2.0+.
      class SymbolArray < Cop
        MSG = 'Use %i or %I for array of symbols.'

        def on_array(node)
          # %i and %I were introduced in Ruby 2.0
          unless RUBY_VERSION < '2.0.0'
            return unless node.loc.begin && node.loc.begin.is?('[')

            array_elems = node.children

            # no need to check empty arrays
            return unless array_elems && array_elems.size > 1

            symbol_array = array_elems.all? { |e| e.type == :sym }

            convention(node, :expression) if symbol_array
          end
        end
      end
    end
  end
end
