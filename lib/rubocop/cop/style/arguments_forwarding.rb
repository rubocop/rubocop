# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # In Ruby 2.7, arguments forwarding has been added.
      #
      # This cop identifies places where `do_something(*args, &block)`
      # can be replaced by `do_something(...)`.
      #
      # @example
      #   # bad
      #   def foo(*args, &block)
      #     bar(*args, &block)
      #   end
      #
      #   # bad
      #   def foo(*args, **kwargs, &block)
      #     bar(*args, **kwargs, &block)
      #   end
      #
      #   # good
      #   def foo(...)
      #     bar(...)
      #   end
      #
      # @example AllowOnlyRestArgument: true (default)
      #   # good
      #   def foo(*args)
      #     bar(*args)
      #   end
      #
      # @example AllowOnlyRestArgument: false
      #   # bad
      #   # The following code can replace the arguments with `...`,
      #   # but it will change the behavior. Because `...` forwards block also.
      #   def foo(*args)
      #     bar(*args)
      #   end
      #
      class ArgumentsForwarding < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.7

        MSG = 'Use arguments forwarding.'

        # @!method use_rest_arguments?(node)
        def_node_matcher :use_rest_arguments?, <<~PATTERN
          (args (restarg $_) $...)
        PATTERN

        # @!method only_rest_arguments?(node, name)
        def_node_matcher :only_rest_arguments?, <<~PATTERN
          (send _ _ (splat (lvar %1)))
        PATTERN

        # @!method forwarding_method_arguments?(node, rest_name, block_name, kwargs_name)
        def_node_matcher :forwarding_method_arguments?, <<~PATTERN
          {
            (send _ _
              (splat (lvar %1))
              (block-pass (lvar %2)))
            (send _ _
              (splat (lvar %1))
              (hash (kwsplat (lvar %3)))
              (block-pass (lvar %2)))
          }
        PATTERN

        def on_def(node)
          return unless node.body
          return unless (rest_args_name, args = use_rest_arguments?(node.arguments))

          node.each_descendant(:send) do |send_node|
            kwargs_name, block_name = extract_argument_names_from(args)

            next unless forwarding_method?(send_node, rest_args_name, kwargs_name, block_name) &&
                        all_lvars_as_forwarding_method_arguments?(node, send_node)

            register_offense_to_forwarding_method_arguments(send_node)
            register_offense_to_method_definition_arguments(node)
          end
        end
        alias on_defs on_def

        private

        def extract_argument_names_from(args)
          kwargs_name = args.first.source.delete('**') if args.first&.kwrestarg_type?
          block_arg_name = args.last.source.delete('&') if args.last&.blockarg_type?

          [kwargs_name, block_arg_name].map { |name| name&.to_sym }
        end

        def forwarding_method?(node, rest_arg, kwargs, block_arg)
          return only_rest_arguments?(node, rest_arg) unless allow_only_rest_arguments?

          forwarding_method_arguments?(node, rest_arg, block_arg, kwargs)
        end

        def all_lvars_as_forwarding_method_arguments?(def_node, forwarding_method)
          lvars = def_node.body.each_descendant(:lvar, :lvasgn)

          begin_pos = forwarding_method.source_range.begin_pos
          end_pos = forwarding_method.source_range.end_pos

          lvars.all? do |lvar|
            lvar.source_range.begin_pos.between?(begin_pos, end_pos)
          end
        end

        def register_offense_to_forwarding_method_arguments(forwarding_method)
          add_offense(arguments_range(forwarding_method)) do |corrector|
            range = range_between(
              forwarding_method.loc.selector.end_pos, forwarding_method.source_range.end_pos
            )
            corrector.replace(range, '(...)')
          end
        end

        def register_offense_to_method_definition_arguments(method_definition)
          add_offense(arguments_range(method_definition)) do |corrector|
            arguments_range = range_with_surrounding_space(
              range: method_definition.arguments.source_range, side: :left
            )
            corrector.replace(arguments_range, '(...)')
          end
        end

        def arguments_range(node)
          arguments = node.arguments

          range_between(arguments.first.source_range.begin_pos, arguments.last.source_range.end_pos)
        end

        def allow_only_rest_arguments?
          cop_config.fetch('AllowOnlyRestArgument', true)
        end
      end
    end
  end
end
