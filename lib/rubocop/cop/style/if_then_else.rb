# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Common functionality for cops checking if and unless statements.
      module IfThenElse
        def on_if(node)
          check(node)
        end

        def on_unless(node)
          check(node)
        end

        def check(node)
          # We won't check modifier or ternary conditionals.
          if node.loc.expression.source =~ /\A(if|unless)\b/
            if offending_line(node)
              convention(node, :expression, error_message)
            end
          end
        end
      end
    end
  end
end
