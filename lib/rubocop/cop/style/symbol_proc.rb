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
          block_send, block_args, block_body = *node

          _breceiver, bmethod_name, bargs = *block_send

          # TODO: Rails-specific handling that we should probably make
          # configurable - https://github.com/bbatsov/rubocop/issues/1485
          # we should ignore lambdas & procs
          return if block_send == PROC_NODE
          return if [:lambda, :proc].include?(bmethod_name)
          return if ignored_method?(bmethod_name)
          # File.open(file) { |f| f.readlines }
          return if bargs
          return unless can_shorten?(block_args, block_body)

          _receiver, method_name, _args = *block_body
          add_offense(node,
                      :expression,
                      format(MSG,
                             method_name,
                             bmethod_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            _block_method, _block_args, block_body = *node
            _receiver, method_name, _args = *block_body

            block_range =
              Parser::Source::Range.new(node.loc.expression.source_buffer,
                                        node.loc.begin.begin_pos,
                                        node.loc.end.end_pos)

            corrector.replace(range_with_surrounding_space(block_range, :left),
                              "(&:#{method_name})")
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
          return false unless block_body && block_body.type == :send

          receiver, _method_name, args = *block_body

          # method in block must be invoked on a lvar without args
          return false if args
          return false unless receiver && receiver.type == :lvar

          block_arg_name, = *block_args.children.first
          receiver_name, = *receiver

          block_arg_name == receiver_name
        end
      end
    end
  end
end
