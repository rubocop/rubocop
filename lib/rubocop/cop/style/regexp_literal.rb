# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class RegexpLiteral < Cop
        MSG = 'Use %%r %sfor regular expressions matching more ' +
          "than one '/' character."

        def on_regexp(node)
          slashes = node.loc.expression.source[1...-1].scan(/\//).size
          msg = if node.loc.begin.is?('/')
                  sprintf(MSG, '') if slashes > 1
                else
                  sprintf(MSG, 'only ') if slashes <= 1
                end
          add_offence(:convention, node.loc.expression, msg) if msg

          super
        end
      end
    end
  end
end
