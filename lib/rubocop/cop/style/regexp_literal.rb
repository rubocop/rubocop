# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for regexp literals and reports offences based
      # on how many escaped slashes there are in the regexp and on the
      # value of the configuration parameter MaxSlashes.
      class RegexpLiteral < Cop
        def on_regexp(node)
          string_parts = node.children.select { |child| child.type == :str }
          total_string = string_parts.map { |s| s.loc.expression.source }.join
          slashes = total_string.count('/')
          msg = if node.loc.begin.is?('/')
                  error_message('') if slashes > max_slashes
                else
                  error_message('only ') if slashes <= max_slashes
                end
          convention(node, :expression, msg) if msg
        end

        def max_slashes
          cop_config['MaxSlashes']
        end

        private

        def error_message(word)
          sprintf('Use %%r %sfor regular expressions matching more ' +
                  "than %d '/' character%s.",
                  word,
                  max_slashes,
                  max_slashes == 1 ? '' : 's')
        end
      end
    end
  end
end
