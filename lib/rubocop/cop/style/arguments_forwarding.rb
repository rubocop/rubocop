# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # In Ruby 2.7, arguments forwarding has been added.
      #
      # This cop identifies places where `do_something(*args, &block)`
      # can be replaced by `do_something(...)`.
      #
      # In Ruby 3.2, anonymous args/kwargs forwarding has been added.
      #
      # This cop also identifies places where `use_args(*args)`/`use_kwargs(**kwargs)` can be
      # replaced by `use_args(*)`/`use_kwargs(**)`; if desired, this functionality can be disabled
      # by setting UseAnonymousForwarding: false.
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
      # @example UseAnonymousForwarding: true (default, only relevant for Ruby >= 3.2)
      #   # bad
      #   def foo(*args, **kwargs)
      #     args_only(*args)
      #     kwargs_only(**kwargs)
      #   end
      #
      #   # good
      #   def foo(*, **)
      #     args_only(*)
      #     kwargs_only(**)
      #   end
      #
      # @example UseAnonymousForwarding: false (only relevant for Ruby >= 3.2)
      #   # good
      #   def foo(*args, **kwargs)
      #     args_only(*args)
      #     kwargs_only(**kwargs)
      #   end
      #
      # @example AllowOnlyRestArgument: true (default, only relevant for Ruby < 3.2)
      #   # good
      #   def foo(*args)
      #     bar(*args)
      #   end
      #
      #   def foo(**kwargs)
      #     bar(**kwargs)
      #   end
      #
      # @example AllowOnlyRestArgument: false (only relevant for Ruby < 3.2)
      #   # bad
      #   # The following code can replace the arguments with `...`,
      #   # but it will change the behavior. Because `...` forwards block also.
      #   def foo(*args)
      #     bar(*args)
      #   end
      #
      #   def foo(**kwargs)
      #     bar(**kwargs)
      #   end
      #
      class ArgumentsForwarding < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.7

        FORWARDING_LVAR_TYPES = %i[splat kwsplat block_pass].freeze

        FORWARDING_MSG = 'Use shorthand syntax `...` for arguments forwarding.'
        ARGS_MSG = 'Use anonymous positional arguments forwarding (`*`).'
        KWARGS_MSG = 'Use anonymous keyword arguments forwarding (`**`).'

        def on_def(node)
          return unless node.body

          forwardable_args = extract_forwardable_args(node.arguments)

          send_classifications = classify_send_nodes(
            node,
            node.each_descendant(:send).to_a,
            non_splat_or_block_pass_lvar_references(node.body),
            forwardable_args
          )

          return if send_classifications.empty?

          if only_forwards_all?(send_classifications)
            add_forward_all_offenses(node, send_classifications)
          elsif target_ruby_version >= 3.2
            add_post_ruby_32_offenses(node, send_classifications, forwardable_args)
          end
        end

        alias on_defs on_def

        private

        def extract_forwardable_args(args)
          [args.find(&:restarg_type?), args.find(&:kwrestarg_type?), args.find(&:blockarg_type?)]
        end

        def only_forwards_all?(send_classifications)
          send_classifications.each_value.all? { |c, _, _| c == :all }
        end

        def add_forward_all_offenses(node, send_classifications)
          send_classifications.each_key do |send_node|
            register_forward_all_offense_on_forwarding_method(send_node)
          end

          register_forward_all_offense_on_method_def(node)
        end

        def add_post_ruby_32_offenses(def_node, send_classifications, forwardable_args)
          return unless use_anonymous_forwarding?

          rest_arg, kwrest_arg, _block_arg = *forwardable_args

          send_classifications.each do |send_node, (_c, forward_rest, forward_kwrest)|
            if forward_rest
              register_forward_args_offense(def_node.arguments, rest_arg)
              register_forward_args_offense(send_node, forward_rest)
            end

            if forward_kwrest
              register_forward_kwargs_offense(!forward_rest, def_node.arguments, kwrest_arg)
              register_forward_kwargs_offense(!forward_rest, send_node, forward_kwrest)
            end
          end
        end

        def non_splat_or_block_pass_lvar_references(body)
          body.each_descendant(:lvar, :lvasgn).filter_map do |lvar|
            parent = lvar.parent

            next if lvar.lvar_type? && FORWARDING_LVAR_TYPES.include?(parent.type)

            lvar.children.first
          end.uniq
        end

        def classify_send_nodes(def_node, send_nodes, referenced_lvars, forwardable_args)
          send_nodes.to_h do |send_node|
            classification_and_forwards = classification_and_forwards(
              def_node,
              send_node,
              referenced_lvars,
              forwardable_args
            )

            [send_node, classification_and_forwards]
          end.compact
        end

        def classification_and_forwards(def_node, send_node, referenced_lvars, forwardable_args)
          classifier = SendNodeClassifier.new(
            def_node,
            send_node,
            referenced_lvars,
            forwardable_args,
            target_ruby_version: target_ruby_version,
            allow_only_rest_arguments: allow_only_rest_arguments?
          )

          classification = classifier.classification

          return unless classification

          [classification, classifier.forwarded_rest_arg, classifier.forwarded_kwrest_arg]
        end

        def register_forward_args_offense(def_arguments_or_send, rest_arg_or_splat)
          add_offense(rest_arg_or_splat, message: ARGS_MSG) do |corrector|
            unless parentheses?(def_arguments_or_send)
              add_parentheses(def_arguments_or_send, corrector)
            end

            corrector.replace(rest_arg_or_splat, '*')
          end
        end

        def register_forward_kwargs_offense(add_parens, def_arguments_or_send, kwrest_arg_or_splat)
          add_offense(kwrest_arg_or_splat, message: KWARGS_MSG) do |corrector|
            if add_parens && !parentheses?(def_arguments_or_send)
              add_parentheses(def_arguments_or_send, corrector)
            end

            corrector.replace(kwrest_arg_or_splat, '**')
          end
        end

        def register_forward_all_offense_on_forwarding_method(forwarding_method)
          add_offense(arguments_range(forwarding_method), message: FORWARDING_MSG) do |corrector|
            begin_pos = forwarding_method.loc.selector&.end_pos || forwarding_method.loc.dot.end_pos
            range = range_between(begin_pos, forwarding_method.source_range.end_pos)

            corrector.replace(range, '(...)')
          end
        end

        def register_forward_all_offense_on_method_def(method_definition)
          add_offense(arguments_range(method_definition), message: FORWARDING_MSG) do |corrector|
            arguments_range = range_with_surrounding_space(
              method_definition.arguments.source_range, side: :left
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

        def use_anonymous_forwarding?
          cop_config.fetch('UseAnonymousForwarding', false)
        end

        # Classifies send nodes for possible rest/kwrest/all (including block) forwarding.
        class SendNodeClassifier
          extend NodePattern::Macros

          # @!method forwarded_rest_arg?(node, rest_name)
          def_node_matcher :forwarded_rest_arg?, '(splat (lvar %1))'

          # @!method extract_forwarded_kwrest_arg(node, kwrest_name)
          def_node_matcher :extract_forwarded_kwrest_arg, '(hash <$(kwsplat (lvar %1)) ...>)'

          # @!method forwarded_block_arg?(node, block_name)
          def_node_matcher :forwarded_block_arg?, '(block_pass {(lvar %1) nil?})'

          def initialize(def_node, send_node, referenced_lvars, forwardable_args, **config)
            @def_node = def_node
            @send_node = send_node
            @referenced_lvars = referenced_lvars
            @rest_arg, @kwrest_arg, @block_arg = *forwardable_args
            @rest_arg_name, @kwrest_arg_name, @block_arg_name =
              *forwardable_args.map { |a| a&.name }
            @config = config
          end

          def forwarded_rest_arg
            return nil if referenced_rest_arg?

            arguments.find { |arg| forwarded_rest_arg?(arg, @rest_arg_name) }
          end

          def forwarded_kwrest_arg
            return nil if referenced_kwrest_arg?

            arguments.filter_map { |arg| extract_forwarded_kwrest_arg(arg, @kwrest_arg_name) }.first
          end

          def forwarded_block_arg
            return nil if referenced_block_arg?

            arguments.find { |arg| forwarded_block_arg?(arg, @block_arg_name) }
          end

          def classification
            return nil unless forwarded_rest_arg || forwarded_kwrest_arg

            if referenced_none? && (forwarded_exactly_all? || pre_ruby_32_allow_forward_all?)
              :all
            elsif target_ruby_version >= 3.2
              :rest_or_kwrest
            end
          end

          private

          def arguments
            @send_node.arguments
          end

          def referenced_rest_arg?
            @referenced_lvars.include?(@rest_arg_name)
          end

          def referenced_kwrest_arg?
            @referenced_lvars.include?(@kwrest_arg_name)
          end

          def referenced_block_arg?
            @referenced_lvars.include?(@block_arg_name)
          end

          def referenced_none?
            !(referenced_rest_arg? || referenced_kwrest_arg? || referenced_block_arg?)
          end

          def forwarded_exactly_all?
            @send_node.arguments.size == 3 &&
              forwarded_rest_arg &&
              forwarded_kwrest_arg &&
              forwarded_block_arg
          end

          def target_ruby_version
            @config.fetch(:target_ruby_version)
          end

          def pre_ruby_32_allow_forward_all?
            target_ruby_version < 3.2 &&
              @def_node.arguments.none?(&:default?) &&
              (@block_arg ? forwarded_block_arg : !@config.fetch(:allow_only_rest_arguments))
          end
        end
      end
    end
  end
end
