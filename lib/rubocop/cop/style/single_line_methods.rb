# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class SingleLineMethods < Cop
        MSG = 'Avoid single-line method definitions.'

        def allow_empty?
          SingleLineMethods.config['AllowIfMethodIsEmpty']
        end

        def on_def(node)
          check(node)

          super
        end

        def on_defs(node)
          check(node)

          super
        end

        private

        def check(node)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          if node.type == :def
            empty_body = node.children[2].nil?
          else
            empty_body = node.children[3].nil?
          end

          if start_line == end_line && !(allow_empty? && empty_body)
            add_offence(:convention,
                        node.loc.expression,
                        MSG)
          end
        end
      end
    end
  end
end
