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

        # We process regexp nodes because the inner str nodes can cause
        # confusion in on_str if they start with %( or %Q(.
        def on_regexp(node)
          string_parts = node.children.select { |child| child.type == :str }
          string_parts.each { |s| ignore_node(s) }
        end

        private

        def check(node)
          if node.loc.respond_to?(:heredoc_body)
            ignore_node(node)
            return
          end
          return if ignored_node?(node) || part_of_ignored_node?(node)
          src = node.loc.expression.source
          return unless src.start_with?('%q') || src.start_with?('%Q')
          return if src =~ /'/ && src =~ /"/
          return if src =~ StringHelp::ESCAPED_CHAR_REGEXP

          extra = if src.start_with?('%Q')
                    ', or for dynamic strings that contain double quotes'
                  else
                    ''
                  end
          add_offense(node, :expression, format(MSG, src[0, 2], extra))
        end

        def autocorrect(node)
          delimiter = node.loc.expression.source =~ /^%Q[^"]+$|'/ ? '"' : "'"
          lambda do |corrector|
            corrector.replace(node.loc.begin, delimiter)
            corrector.replace(node.loc.end, delimiter)
          end
        end
      end
    end
  end
end
