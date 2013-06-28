# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly.
      #
      # The cop should be made configurable since when assignment is factored
      # in, two alignment schemes generally make sense.
      class EndAlignment < Cop
        MSG = 'end at %d, %d is not aligned with %s at %d, %d'

        def initialize
          super
          @inspected_blocks = []
        end

        def inspect(source_buffer, source, tokens, ast, comments)
          @inspected_blocks = []
          super
        end

        def on_def(node)
          check(node)
          super
        end

        def on_defs(node)
          check(node)
          super
        end

        def on_class(node)
          check(node)
          super
        end

        def on_module(node)
          check(node)
          super
        end

        def on_if(node)
          check(node) if node.loc.respond_to?(:end)
          super
        end

        def on_while(node)
          check(node)
          super
        end

        def on_until(node)
          check(node)
          super
        end

        # Block related alignments

        def on_block(node)
          return if already_processed_node?(node)
          check_block_alignment(node.loc.expression, node.loc)
          super
        end

        def on_lvasgn(node)
          _, children = *node
          process_block_assignment(node, children)
          super
        end

        alias_method :on_ivasgn,   :on_lvasgn
        alias_method :on_cvasgn,   :on_lvasgn
        alias_method :on_gvasgn,   :on_lvasgn
        alias_method :on_and_asgn, :on_lvasgn
        alias_method :on_or_asgn,  :on_lvasgn

        def on_casgn(node)
          _, _, children = *node
          process_block_assignment(node, children)
          super
        end

        def on_op_asgn(node)
          variable, _op, args = *node
          process_block_assignment(variable, args)
          super
        end

        def on_send(node)
          receiver, method, args = *node
          if attribute_writer?(method)
            process_block_assignment(receiver, args)
          end
          super
        end

        def on_masgn(node)
          variables, args = *node
          process_block_assignment(variables, args)
          super
        end

        private

        def process_block_assignment(begin_node, block_node)
          if block_node && block_node.type == :block
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

        def attribute_writer?(method)
          method.to_s[-1] == '='
        end
      end
    end
  end
end
