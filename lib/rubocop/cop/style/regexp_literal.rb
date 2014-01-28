# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for regexp literals and reports offences based
      # on how many escaped slashes there are in the regexp and on the
      # value of the configuration parameter MaxSlashes.
      class RegexpLiteral < Cop
        include ConfigurableMax

        def on_regexp(node)
          string_parts = node.children.select { |child| child.type == :str }
          total_string = string_parts.map { |s| s.loc.expression.source }.join
          slashes = total_string.count('/')
          if node.loc.begin.is?('/')
            if slashes > max_slashes
              msg = error_message('')
              safe_setting = slashes
            end
          elsif slashes <= max_slashes
            msg = error_message('only ')
            safe_setting = slashes + 1
          end

          if msg
            add_offence(node, :expression, msg) { self.max = safe_setting }
          end
        end

        def max_slashes
          cop_config['MaxSlashes']
        end

        private

        def parameter_name
          'MaxSlashes'
        end

        def error_message(word)
          sprintf('Use %%r %sfor regular expressions matching more ' \
                  "than %d '/' character%s.",
                  word,
                  max_slashes,
                  max_slashes == 1 ? '' : 's')
        end
      end
    end
  end
end
