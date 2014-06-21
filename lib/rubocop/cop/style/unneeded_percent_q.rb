# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of the %q/%Q syntax when '' or "" would do.
      class UnneededPercentQ < Cop
        MSG = 'Use `%s` only for strings that contain both single quotes and ' \
              'double quotes%s.'

        def on_dstr(node)
          # Using %Q to avoid escaping inner " is ok.
          check(node) unless node.loc.expression.source =~ /"/
        end

        def on_str(node)
          check(node)
        end

        private

        def check(node)
          src = node.loc.expression.source
          return unless src =~ /^%q/i
          return if src =~ /'/ && src =~ /"/

          extra = if src =~ /^%Q/
                    ', or for dynamic strings that contain double quotes'
                  else
                    ''
                  end
          add_offense(node, :expression, format(MSG, src[0, 2], extra))
        end

        def autocorrect(node)
          delimiter = node.loc.expression.source =~ /^%Q[^"]+$|'/ ? '"' : "'"
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, delimiter)
            corrector.replace(node.loc.end, delimiter)
          end
        end
      end
    end
  end
end
