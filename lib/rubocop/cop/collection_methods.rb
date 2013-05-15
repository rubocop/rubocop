# encoding: utf-8

module Rubocop
  module Cop
    class CollectionMethods < Cop
      PREFERRED_METHODS = {
        collect: 'map',
        inject: 'reduce',
        detect: 'find',
        find_all: 'select'
      }

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |node|
          _receiver, method_name, *_args = *node

          if PREFERRED_METHODS[method_name]
            add_offence(
              :convention,
              node.src.line,
              "Prefer #{PREFERRED_METHODS[method_name]} over #{method_name}."
            )
          end
        end
      end
    end
  end
end
