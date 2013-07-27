# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for regexp literals and reports offences based
      # on how many escaped slashes there are in the regexp and on the
      # value of the configuration parameter MaxSlashes.
      class RegexpLiteral < Cop
        def on_regexp(node)
          slashes = node.loc.expression.source.count('/')
          max = RegexpLiteral.max_slashes
          msg = if node.loc.begin.is?('/')
                  slashes -= 2 # subtract delimiters
                  error_message('') if slashes > max
                else
                  error_message('only ') if slashes <= max
                end
          add_offence(:convention, node.loc.expression, msg) if msg
        end

        def self.max_slashes
          RegexpLiteral.config['MaxSlashes']
        end

        private

        def error_message(word)
          sprintf('Use %%r %sfor regular expressions matching more ' +
                  "than %d '/' character%s.",
                  word,
                  RegexpLiteral.max_slashes,
                  RegexpLiteral.max_slashes == 1 ? '' : 's')
        end
      end
    end
  end
end
