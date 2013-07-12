# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly.
      #
      # For keywords (if, def, etc.) the end is aligned with the start
      # of the keyword.
      # For blocks - with the start of the expression where the block
      # is defined.
      #
      # @example
      #
      #   variable = if true
      #              end
      #
      #   variable = lambda do |i|
      #     i
      #   end
      class EndAlignment < Cop
        MSG = 'end at %d, %d is not aligned with %s at %d, %d'

        def initialize
          super
          @inspected_blocks = []
        end

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        def on_class(node)
          check(node)
        end

        def on_module(node)
          check(node)
        end

        def on_if(node)
          check(node) if node.loc.respond_to?(:end)
        end

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        # Block related alignments

        def on_block(node)
          return if already_processed_node?(node)
          check_block_alignment(node.loc.expression, node.loc)
        end

        def on_and(node)
          return if already_processed_node?(node)

          _left, right = *node
          if right.type == :block
            check_block_alignment(node.loc.expression, right.loc)
            @inspected_blocks << right
          end
        end

        alias_method :on_or, :on_and

        def on_lvasgn(node)
          _, children = *node
          process_block_assignment(node, children)
        end

        alias_method :on_ivasgn,   :on_lvasgn
        alias_method :on_cvasgn,   :on_lvasgn
        alias_method :on_gvasgn,   :on_lvasgn
        alias_method :on_and_asgn, :on_lvasgn
        alias_method :on_or_asgn,  :on_lvasgn

        def on_casgn(node)
          _, _, children = *node
          process_block_assignment(node, children)
        end

        def on_op_asgn(node)
          variable, _op, args = *node
          process_block_assignment(variable, args)
        end

        def on_send(node)
          _receiver, _method, *args = *node
          process_block_assignment(node, args.last)
        end

        def on_masgn(node)
          variables, args = *node
          process_block_assignment(variables, args)
        end

        private

        def process_block_assignment(begin_node, block_node)
          return unless block_node

          while [:send, :lvasgn].include?(block_node.type)
            if block_node.type == :send
              receiver, _method, args = *block_node
              if receiver && [:block, :send].include?(receiver.type)
                block_node = receiver
              elsif args && [:block, :send].include?(args.type)
                block_node = args
              else
                break
              end
            elsif block_node.type == :lvasgn
              _variable, value = *block_node
              block_node = value
            end
          end

          return if already_processed_node?(block_node)

          if block_node.type == :block
            # If the block is an argument in a function call, align end with
            # the block itself, and not with the function.
            if begin_node.type == :send
              _receiver, method, *_args = *begin_node
              begin_node = block_node if method.to_s =~ /^\w+$/
            end

            # Align with the expression that is on the same line
            # where the block is defined
            return if block_is_on_next_line?(begin_node, block_node)

            @inspected_blocks << block_node
            check_block_alignment(begin_node.loc.expression, block_node.loc)
          end
        end

        def check_block_alignment(start_loc, block_loc)
          end_loc = block_loc.end
          if block_loc.begin.line != end_loc.line &&
               start_loc.column != end_loc.column
            add_offence(:warning,
                        end_loc,
                        sprintf(MSG, end_loc.line, end_loc.column,
                                start_loc.source.lines.to_a.first.chomp,
                                start_loc.line, start_loc.column))
          end
        end

        def check(node)
          # discard modifier forms of if/while/until
          return unless node.loc.end

          kw_loc = node.loc.keyword
          end_loc = node.loc.end

          if kw_loc.line != end_loc.line && kw_loc.column != end_loc.column
            add_offence(:warning,
                        end_loc,
                        sprintf(MSG, end_loc.line, end_loc.column,
                                kw_loc.source, kw_loc.line, kw_loc.column))
          end
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
