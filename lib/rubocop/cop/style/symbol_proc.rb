# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Use symbols as procs when possible.
      #
      # @example
      #   # bad
      #   something.map { |s| s.upcase }
      #
      #   # good
      #   something.map(&:upcase)
      class SymbolProc < Cop
        MSG = 'Pass `&:%s` as an argument to `%s` instead of a block.'

        PROC_NODE = s(:send, s(:const, nil, :Proc), :new)

        def on_block(node)
          block_send_or_super, block_args, block_body = *node

          if super?(block_send_or_super)
            bmethod_name = :super
          else
            _breceiver, bmethod_name, _bargs = *block_send_or_super
          end

          # TODO: Rails-specific handling that we should probably make
          # configurable - https://github.com/bbatsov/rubocop/issues/1485
          # we should ignore lambdas & procs
          return if block_send_or_super == PROC_NODE
          return if [:lambda, :proc].include?(bmethod_name)
          return if ignored_method?(bmethod_name)
          return unless can_shorten?(block_args, block_body)

          _receiver, method_name, _args = *block_body

          sb = node.source_range.source_buffer
          block_start = node.loc.begin.begin_pos
          block_end = node.loc.end.end_pos
          range = Parser::Source::Range.new(sb, block_start, block_end)

          add_offense(node,
                      range,
                      format(MSG,
                             method_name,
                             bmethod_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            block_send_or_super, _block_args, block_body = *node
            _receiver, method_name, _args = *block_body

            if super?(block_send_or_super)
              args = *block_send_or_super
            else
              _breceiver, _bmethod_name, *args = *block_send_or_super
            end
            autocorrect_method(corrector, node, args, method_name)
          end
        end

        def autocorrect_method(corrector, node, args, method_name)
          if args.empty?
            autocorrect_no_args(corrector, node, method_name)
          else
            autocorrect_with_args(corrector, node, args, method_name)
          end
        end

        def autocorrect_no_args(corrector, node, method_name)
          corrector.replace(block_range_with_space(node), "(&:#{method_name})")
        end

        def autocorrect_with_args(corrector, node, args, method_name)
          corrector.insert_after(args.last.source_range, ", &:#{method_name}")
          corrector.remove(block_range_with_space(node))
        end

        def block_range_with_space(node)
          block_range =
            Parser::Source::Range.new(node.source_range.source_buffer,
                                      begin_pos_for_replacement(node),
                                      node.loc.end.end_pos)
          range_with_surrounding_space(block_range, :left)
        end

        def begin_pos_for_replacement(node)
          block_send_or_super, _block_args, _block_body = *node
          expr = block_send_or_super.source_range

          if (paren_pos = (expr.source =~ /\(\s*\)$/))
            expr.begin_pos + paren_pos
          else
            node.loc.begin.begin_pos
          end
        end

        def ignored_methods
          cop_config['IgnoredMethods']
        end

        def ignored_method?(name)
          ignored_methods.include?(name.to_s)
        end

        def can_shorten?(block_args, block_body)
          # something { |x, y| ... }
          return false unless block_args.children.size == 1
          return false if block_args.children.first.blockarg_type?
          return false unless block_body && block_body.type == :send

          receiver, _method_name, args = *block_body

          # method in block must be invoked on a lvar without args
          return false if args
          return false unless receiver && receiver.type == :lvar

          block_arg_name, = *block_args.children.first
          receiver_name, = *receiver

          block_arg_name == receiver_name
        end

        def super?(node)
          [:super, :zsuper].include?(node.type)
        end
      end
    end
  end
end
