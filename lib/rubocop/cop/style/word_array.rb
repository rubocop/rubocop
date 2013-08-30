# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for array literals made up of word-like
      # strings, that are not using the %w() syntax.
      class WordArray < Cop
        MSG = 'Use %w or %W for array of words.'

        def on_array(node)
          return unless node.loc.begin && node.loc.begin.is?('[')

          array_elems = node.children

          # no need to check empty arrays
          return unless array_elems && array_elems.size > 1

          string_array = array_elems.all? { |e| e.type == :str }

          if string_array && !complex_content?(array_elems)
            convention(node, :expression)
          end
        end

        private

        def complex_content?(arr_sexp)
          arr_sexp.each do |s|
            source = s.loc.expression.source
            unless source.start_with?('?') # %W(\r \n) can replace [?\r, ?\n]
              str_content = Util.strip_quotes(source)
              return true unless str_content =~ /\A[\w-]+\z/
            end
          end

          false
        end
      end
    end
  end
end
