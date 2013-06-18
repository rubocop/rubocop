# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class WordArray < Cop
        MSG = 'Use %w or %W for array of words.'

        def on_array(node)
          return unless node.loc.begin && node.loc.begin.is?('[')

          array_elems = node.children

          # no need to check empty arrays
          return unless array_elems && array_elems.size > 1

          string_array = array_elems.all? { |e| e.type == :str }

          if string_array && !complex_content?(array_elems)
            add_offence(:convention, node.loc.expression, MSG)
          end

          super
        end

        private

        def complex_content?(arr_sexp)
          arr_sexp.each do |s|
            str_content = Util.strip_quotes(s.loc.expression.source)
            return true unless str_content =~ /\A[\w-]+\z/
          end

          false
        end
      end
    end
  end
end
