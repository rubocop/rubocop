# encoding: utf-8

module Rubocop
  module Cop
    class CollectionMethods < Cop
      PREFERRED_METHODS = {
        'collect' => 'map',
        'inject' => 'reduce',
        'detect' => 'find',
        'find_all' => 'select',
      }

      def inspect(file, source, tokens, sexp)
        each(:call, sexp) do |s|
          s.drop(2).each_slice(2) do |m|
            method_name = m[1][1]
            if PREFERRED_METHODS[method_name]
              add_offence(
                :convention,
                m[1][2].lineno,
                "Prefer #{PREFERRED_METHODS[method_name]} over #{method_name}."
              )
            end
          end
        end
      end
    end
  end
end
