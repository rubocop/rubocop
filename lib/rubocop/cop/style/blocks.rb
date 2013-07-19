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
            if block
              method_name_regexp = Regexp.escape(method_name)
              args_regexp = args
                .map { |arg| Regexp.escape(arg.loc.expression.source) }
                .join('\s*,\s*')
              if node.loc.expression.source =~
                  /#{method_name_regexp}\s+#{args_regexp}/
                # If there are no parentheses around the arguments, then braces
                # and do-end have different meaning due to how they bind, so we
                # allow either.
                ignore_node(block)
              end
            end
          end
        end

        def on_block(node)
          return if ignored_node?(node)

          block_length = Util.block_length(node)
          block_begin = node.loc.begin.source

          if block_length > 0 && block_begin == '{'
            add_offence(:convention, node.loc.begin, MULTI_LINE_MSG)
          elsif block_length == 0 && block_begin != '{'
            add_offence(:convention, node.loc.begin, SINGLE_LINE_MSG)
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
      end
    end
  end
end
