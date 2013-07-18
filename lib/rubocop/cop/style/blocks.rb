# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Check for uses of braces or do/end around single line or
      # multi-line blocks.
      class Blocks < Cop
        MULTI_LINE_MSG = 'Avoid using {...} for multi-line blocks.'
        SINGLE_LINE_MSG = 'Prefer {...} over do...end for single-line blocks.'

        def investigate(processed_source)
          @allowed_with_braces = []
        end

        def on_send(node)
          _receiver, method_name, *args = *node
          if args.any? && args.last.type == :block
            unless node.loc.expression.source =~ /#{method_name}\s*\(/
              # If there are no parentheses around the arguments, then do-end
              # would change the meaning of the code, so we allow the braces.
              @allowed_with_braces << args.last
            end
          end
        end

        def on_block(node)
          block_length = Util.block_length(node)
          block_begin = node.loc.begin.source

          if block_length > 0 && block_begin == '{'
            unless @allowed_with_braces.include?(node)
              add_offence(:convention, node.loc.begin, MULTI_LINE_MSG)
            end
          elsif block_length == 0 && block_begin != '{'
            add_offence(:convention, node.loc.begin, SINGLE_LINE_MSG)
          end
        end
      end
    end
  end
end
