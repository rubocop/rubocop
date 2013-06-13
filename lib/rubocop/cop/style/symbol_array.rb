# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class SymbolArray < Cop
        MSG = 'Use %i or %I for array of symbols.'

        def on_array(node)
          # %i and %I were introduced in Ruby 2.0
          unless RUBY_VERSION < '2.0.0'
            return unless node.loc.begin && node.loc.begin.source == '['

            array_elems = node.children

            # no need to check empty arrays
            return unless array_elems && array_elems.size > 1

            symbol_array = array_elems.all? { |e| e.type == :sym }

            add_offence(:convention, node.loc.expression, MSG) if symbol_array
          end
        end
      end
    end
  end
end
