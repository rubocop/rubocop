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
            if block && !parentheses?(node) && !operator?(method_name)
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
            add_offence(node, :begin, MULTI_LINE_MSG)
          elsif block_length == 0 && block_begin != '{'
            add_offence(node, :begin, SINGLE_LINE_MSG)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            b, e = node.loc.begin, node.loc.end
            if b.is?('{')
              # If the left brace is immediately preceded by a word character,
              # then we need a space before `do` to get valid Ruby code.
              if b.source_buffer.source[b.begin_pos - 1, 1] =~ /\w/
                corrector.insert_before(b, ' ')
              end
              corrector.replace(b, 'do')
              corrector.replace(e, 'end')
            else
              corrector.replace(b, '{')
              corrector.replace(e, '}')
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

        def parentheses?(send_node)
          send_node.loc.begin
        end

        def operator?(method_name)
          method_name =~ /^\W/
        end
      end
    end
  end
end
