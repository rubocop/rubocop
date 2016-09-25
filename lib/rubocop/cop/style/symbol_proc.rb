# frozen_string_literal: true

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
        MSG = 'Pass `&:%s` as an argument to `%s` instead of a block.'.freeze

        PROC_NODE = s(:send, s(:const, nil, :Proc), :new)

        def on_block(node)
          block_send_or_super, block_args, block_body = *node
          block_method_name = resolve_block_method_name(block_send_or_super)

          # TODO: Rails-specific handling that we should probably make
          # configurable - https://github.com/bbatsov/rubocop/issues/1485
          # we should ignore lambdas & procs
          return if block_send_or_super == PROC_NODE
          return if [:lambda, :proc].include?(block_method_name)
          return if ignored_method?(block_method_name)
          return unless can_shorten?(block_args, block_body)

          _receiver, method_name, _args = *block_body
          offense(node, method_name, block_method_name)
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

        private

        def resolve_block_method_name(block_send_or_super)
          return :super if super?(block_send_or_super)

          _receiver, method_name, _args = *block_send_or_super
          method_name
        end

        def offense(node, method_name, block_method_name)
          block_start = node.loc.begin.begin_pos
          block_end = node.loc.end.end_pos
          range = range_between(block_start, block_end)

          add_offense(node,
                      range,
                      format(MSG,
                             method_name,
                             block_method_name))
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
          arg_range = args.last.source_range
          arg_range = range_with_surrounding_comma(arg_range, :right)
          replacement = " &:#{method_name}"
          replacement = ',' + replacement unless arg_range.source.end_with?(',')
          corrector.insert_after(arg_range, replacement)
          corrector.remove(block_range_with_space(node))
        end

        def block_range_with_space(node)
          block_range = range_between(begin_pos_for_replacement(node),
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
          return false unless shortenable_args?(block_args) &&
                              shortenable_body?(block_body)

          argument_matches_receiver?(block_args, block_body)
        end

        # TODO: This might be clearer as a node matcher with unification
        def argument_matches_receiver?(block_args, block_body)
          receiver, = *block_body

          block_arg_name, = *block_args.children.first
          receiver_name, = *receiver

          block_arg_name == receiver_name
        end

        # The block body must have a single send without arguments to an
        # lvar type.
        # E.g.: `foo { |bar| bar.baz }`
        def shortenable_body?(block_body)
          return false unless block_body && block_body.send_type?

          receiver, _, args = *block_body

          return false if args

          receiver && receiver.lvar_type?
        end

        # The block must have a single, shortenable argument.
        # E.g.: `foo { |bar| ... }`
        def shortenable_args?(block_args)
          block_args.children.one? && !non_shortenable_args?(block_args)
        end

        def super?(node)
          [:super, :zsuper].include?(node.type)
        end

        def non_shortenable_args?(block_args)
          # something { |&x| ... }
          # something { |*x| ... }
          [:blockarg, :restarg].include?(block_args.children.first.type)
        end
      end
    end
  end
end
