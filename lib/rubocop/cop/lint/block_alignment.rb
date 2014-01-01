# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly for do
      # end blocks.
      #
      # @example
      #
      #   variable = lambda do |i|
      #     i
      #   end
      class BlockAlignment < Cop
        include CheckAssignment

        MSG = 'end at %d, %d is not aligned with %s at %d, %d%s'

        def initialize(config = nil, options = nil)
          super
          @inspected_blocks = []
        end

        def on_block(node)
          return if already_processed_node?(node)
          check_block_alignment(node, node)
        end

        def on_and(node)
          return if already_processed_node?(node)

          _left, right = *node
          if right.type == :block
            check_block_alignment(node, right)
            @inspected_blocks << right
          end
        end

        alias_method :on_or, :on_and

        def on_op_asgn(node)
          variable, _op, args = *node
          check_assignment(variable, args)
        end

        def on_send(node)
          _receiver, _method, *args = *node
          check_assignment(node, args.last)
        end

        def on_masgn(node)
          variables, args = *node
          check_assignment(variables, args)
        end

        private

        def check_assignment(begin_node, other_node)
          return unless other_node

          block_node = find_block_node(other_node)
          return unless block_node.type == :block

          # If the block is an argument in a function call, align end with
          # the block itself, and not with the function.
          if begin_node.type == :send
            _receiver, method, *_args = *begin_node
            begin_node = block_node if method.to_s =~ /^\w+$/
          end

          # Align with the expression that is on the same line
          # where the block is defined
          if begin_node.type != :mlhs && block_is_on_next_line?(begin_node,
                                                                block_node)
            return
          end
          return if already_processed_node?(block_node)

          @inspected_blocks << block_node
          check_block_alignment(begin_node, block_node)
        end

        def find_block_node(node)
          while [:send, :lvasgn].include?(node.type)
            n = case node.type
                when :send
                  find_block_or_send_node(node) || break
                when :lvasgn
                  _variable, value = *node
                  value
                end
            node = n if n
          end
          node
        end

        def find_block_or_send_node(send_node)
          receiver, _method, args = *send_node
          [receiver, args].find do |subnode|
            subnode && [:block, :send].include?(subnode.type)
          end
        end

        def check_block_alignment(start_node, block_node)
          start_loc = start_node.loc.expression
          end_loc = block_node.loc.end
          do_loc = block_node.loc.begin # Actually it's either do or {.
          return if do_loc.line == end_loc.line # One-liner, not interesting.
          if start_loc.column != end_loc.column
            # We've found that "end" is not aligned with the start node (which
            # can be a block, a variable assignment, etc). But we also allow
            # the "end" to be aligned with the start of the line where the "do"
            # is, which is a style some people use in multi-line chains of
            # blocks.
            match = /\S.*/.match(do_loc.source_line)
            indentation_of_do_line = match.begin(0)
            if end_loc.column != indentation_of_do_line
              add_offence(nil,
                          end_loc,
                          sprintf(MSG, end_loc.line, end_loc.column,
                                  start_loc.source.lines.to_a.first.chomp,
                                  start_loc.line, start_loc.column,
                                  alt_start_msg(match, start_loc, do_loc,
                                                indentation_of_do_line)))
            end
          end
        end

        def alt_start_msg(match, start_loc, do_loc, indentation_of_do_line)
          if start_loc.line == do_loc.line &&
              start_loc.column == indentation_of_do_line
            ''
          else
            " or #{match[0]} at #{do_loc.line}, #{indentation_of_do_line}"
          end
        end

        def message
        end

        def already_processed_node?(node)
          @inspected_blocks.include?(node)
        end

        def block_is_on_next_line?(begin_node, block_node)
          begin_node.loc.line != block_node.loc.line
        end
      end
    end
  end
end
