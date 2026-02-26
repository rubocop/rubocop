# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of explicit block argument to avoid writing
      # block literal that just passes its arguments to another block.
      #
      # NOTE: This cop only registers an offense if the block args match the
      # yield args exactly.
      #
      # @example
      #   # bad
      #   def with_tmp_dir
      #     Dir.mktmpdir do |tmp_dir|
      #       Dir.chdir(tmp_dir) { |dir| yield dir } # block just passes arguments
      #     end
      #   end
      #
      #   # bad
      #   def nine_times
      #     9.times { yield }
      #   end
      #
      #   # good
      #   def with_tmp_dir(&block)
      #     Dir.mktmpdir do |tmp_dir|
      #       Dir.chdir(tmp_dir, &block)
      #     end
      #   end
      #
      #   with_tmp_dir do |dir|
      #     puts "dir is accessible as a parameter and pwd is set: #{dir}"
      #   end
      #
      #   # good
      #   def nine_times(&block)
      #     9.times(&block)
      #   end
      #
      class ExplicitBlockArgument < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Consider using explicit block argument in the '\
              "surrounding method's signature over `yield`."

        # @!method yielding_block?(node)
        def_node_matcher :yielding_block?, <<~PATTERN
          (block $_ (args $...) (yield $...))
        PATTERN

        def initialize(config = nil, options = nil)
          super
          @def_nodes = Set.new
        end

        def on_yield(node)
          block_node = node.parent

          yielding_block?(block_node) do |send_node, block_args, yield_args|
            return unless yielding_arguments?(block_args, yield_args)

            def_node = block_node.each_ancestor(:def, :defs).first
            # if `yield` is being called outside of a method context, ignore
            # this is not a valid ruby pattern, but can happen in haml or erb,
            # so this can cause crashes in haml_lint
            return unless def_node

            add_offense(block_node) do |corrector|
              corrector.remove(block_body_range(block_node, send_node))

              add_block_argument(send_node, corrector)
              add_block_argument(def_node, corrector) if @def_nodes.add?(def_node)
            end
          end
        end

        private

        def yielding_arguments?(block_args, yield_args)
          yield_args = yield_args.dup.fill(
            nil,
            yield_args.length, block_args.length - yield_args.length
          )

          yield_args.zip(block_args).all? do |yield_arg, block_arg|
            next false unless yield_arg && block_arg

            block_arg && yield_arg.children.first == block_arg.children.first
          end
        end

        def add_block_argument(node, corrector)
          if node.arguments?
            last_arg = node.arguments.last
            arg_range = range_with_surrounding_comma(last_arg.source_range, :right)
            replacement = ' &block'
            replacement = ",#{replacement}" unless arg_range.source.end_with?(',')
            corrector.insert_after(arg_range, replacement) unless last_arg.blockarg_type?
          elsif node.call_type? || node.zsuper_type?
            corrector.insert_after(node, '(&block)')
          else
            corrector.insert_after(node.loc.name, '(&block)')
          end
        end

        def block_body_range(block_node, send_node)
          range_between(
            send_node.loc.expression.end_pos,
            block_node.loc.end.end_pos
          )
        end
      end
    end
  end
end
