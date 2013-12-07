# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for single-line method definitions.
      # It can optionally accept single-line methods with no body.
      class SingleLineMethods < Cop
        include CheckMethods

        MSG = 'Avoid single-line method definitions.'

        def allow_empty?
          cop_config['AllowIfMethodIsEmpty']
        end

        private

        def check(node, _method_name, _args, body)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          empty_body = body.nil?

          if start_line == end_line && !(allow_empty? && empty_body)
            add_offence(node, :expression)
          end
        end
      end
    end
  end
end
