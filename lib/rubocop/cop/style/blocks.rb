# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Check for uses of braces or do/end around single line or
      # multi-line blocks.
      class Blocks < Cop
        MULTI_LINE_MSG = 'Avoid using {...} for multi-line blocks.'
        SINGLE_LINE_MSG = 'Prefer {...} over do...end for single-line blocks.'

        def on_send(node)
          _receiver, method_name, *args = *node
          if args.any?
            block = get_block(args.last)
            if block && !has_parentheses?(node) && !operator?(method_name)
              # If there are no parentheses around the arguments, then braces
              # and do-end have different meaning due to how they bind, so we
              # allow either.
              ignore_node(block)
            end
          end
        end

        def on_block(node)
          return if ignored_node?(node)

          block_length = Util.block_length(node)
          block_begin = node.loc.begin.source

          if block_length > 0 && block_begin == '{'
            convention(node, :begin, MULTI_LINE_MSG)
          elsif block_length == 0 && block_begin != '{'
            convention(node, :begin, SINGLE_LINE_MSG)
          end
        end

        def autocorrect_action(node)
          @corrections << lambda do |corrector|
            if node.loc.begin.is?('{')
              corrector.replace(node.loc.begin, 'do')
              corrector.replace(node.loc.end, 'end')
            else
              corrector.replace(node.loc.begin, '{')
              corrector.replace(node.loc.end, '}')
            end
          end
        end

        private

        def get_block(node)
          case node.type
          when :block
            node
          when :send
            receiver, _method_name, *_args = *node
            get_block(receiver) if receiver
          end
        end

        def has_parentheses?(send_node)
          send_node.loc.begin
        end

        def operator?(method_name)
          method_name =~ /^\W/
        end
      end
    end
  end
end
