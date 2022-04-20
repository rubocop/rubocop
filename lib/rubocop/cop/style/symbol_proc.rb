# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use symbols as procs when possible.
      #
      # If you prefer a style that allows block for method with arguments,
      # please set `true` to `AllowMethodsWithArguments`.
      #
      # @safety
      #   This cop is unsafe because `proc`s and blocks work differently
      #   when additional arguments are passed in. A block will silently
      #   ignore additional arguments, but a `proc` will raise
      #   an `ArgumentError`.
      #
      #   For example:
      #
      #   [source,ruby]
      #   ----
      #   class Foo
      #     def bar
      #       :bar
      #     end
      #   end
      #
      #   def call(options = {}, &block)
      #     block.call(Foo.new, options)
      #   end
      #
      #   call { |x| x.bar }
      #   #=> :bar
      #   call(&:bar)
      #   # ArgumentError: wrong number of arguments (given 1, expected 0)
      #   ----
      #
      # @example
      #   # bad
      #   something.map { |s| s.upcase }
      #   something.map { _1.upcase }
      #
      #   # good
      #   something.map(&:upcase)
      #
      # @example AllowMethodsWithArguments: false (default)
      #   # bad
      #   something.do_something(foo) { |o| o.bar }
      #
      #   # good
      #   something.do_something(foo, &:bar)
      #
      # @example AllowMethodsWithArguments: true
      #   # good
      #   something.do_something(foo) { |o| o.bar }
      #
      # @example AllowComments: false (default)
      #   # bad
      #   something.do_something do |s| # some comment
      #     # some comment
      #     s.upcase # some comment
      #     # some comment
      #   end
      #
      # @example AllowComments: true
      #   # good  - if there are comment in either position
      #   something.do_something do |s| # some comment
      #     # some comment
      #     s.upcase # some comment
      #     # some comment
      #   end
      class SymbolProc < Base
        include CommentsHelp
        include RangeHelp
        include IgnoredMethods
        extend AutoCorrector

        MSG = 'Pass `&:%<method>s` as an argument to `%<block_method>s` instead of a block.'
        SUPER_TYPES = %i[super zsuper].freeze

        # @!method proc_node?(node)
        def_node_matcher :proc_node?, '(send (const {nil? cbase} :Proc) :new)'

        # @!method symbol_proc_receiver?(node)
        def_node_matcher :symbol_proc_receiver?, '{(send ...) (super ...) zsuper}'

        # @!method symbol_proc?(node)
        def_node_matcher :symbol_proc?, <<~PATTERN
          {
            (block $#symbol_proc_receiver? $(args (arg _var)) (send (lvar _var) $_))
            (numblock $#symbol_proc_receiver? $1 (send (lvar :_1) $_))
          }
        PATTERN

        def self.autocorrect_incompatible_with
          [Layout::SpaceBeforeBlockBraces]
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def on_block(node)
          symbol_proc?(node) do |dispatch_node, arguments_node, method_name|
            # TODO: Rails-specific handling that we should probably make
            # configurable - https://github.com/rubocop/rubocop/issues/1485
            # we should ignore lambdas & procs
            return if proc_node?(dispatch_node)
            return if %i[lambda proc].include?(dispatch_node.method_name)
            return if ignored_method?(dispatch_node.method_name)
            return if allow_if_method_has_argument?(node)
            return if node.block_type? && destructuring_block_argument?(arguments_node)
            return if allow_comments? && contains_comments?(node)

            register_offense(node, method_name, dispatch_node.method_name)
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        alias on_numblock on_block

        def destructuring_block_argument?(argument_node)
          argument_node.one? && argument_node.source.include?(',')
        end

        private

        def register_offense(node, method_name, block_method_name)
          block_start = node.loc.begin.begin_pos
          block_end = node.loc.end.end_pos
          range = range_between(block_start, block_end)
          message = format(MSG, method: method_name, block_method: block_method_name)

          add_offense(range, message: message) { |corrector| autocorrect(corrector, node) }
        end

        def autocorrect(corrector, node)
          if node.send_node.arguments?
            autocorrect_with_args(corrector, node, node.send_node.arguments, node.body.method_name)
          else
            autocorrect_without_args(corrector, node)
          end
        end

        def autocorrect_without_args(corrector, node)
          corrector.replace(block_range_with_space(node), "(&:#{node.body.method_name})")
        end

        def autocorrect_with_args(corrector, node, args, method_name)
          arg_range = args.last.source_range
          arg_range = range_with_surrounding_comma(arg_range, :right)
          replacement = " &:#{method_name}"
          replacement = ",#{replacement}" unless arg_range.source.end_with?(',')
          corrector.insert_after(arg_range, replacement)
          corrector.remove(block_range_with_space(node))
        end

        def block_range_with_space(node)
          block_range = range_between(begin_pos_for_replacement(node), node.loc.end.end_pos)
          range_with_surrounding_space(range: block_range, side: :left)
        end

        def begin_pos_for_replacement(node)
          expr = node.send_node.source_range

          if (paren_pos = (expr.source =~ /\(\s*\)$/))
            expr.begin_pos + paren_pos
          else
            node.loc.begin.begin_pos
          end
        end

        def allow_if_method_has_argument?(node)
          !!cop_config.fetch('AllowMethodsWithArguments', false) && !node.arguments.count.zero?
        end

        def allow_comments?
          cop_config.fetch('AllowComments', false)
        end
      end
    end
  end
end
