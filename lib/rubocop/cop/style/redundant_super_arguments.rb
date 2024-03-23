# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant argument forwarding when calling super
      # with arguments identical to the method definition.
      #
      # @example
      #   # bad
      #   def method(*args, **kwargs)
      #     super(*args, **kwargs)
      #   end
      #
      #   # good - implicitly passing all arguments
      #   def method(*args, **kwargs)
      #     super
      #   end
      #
      #   # good - forwarding a subset of the arguments
      #   def method(*args, **kwargs)
      #     super(*args)
      #   end
      #
      #   # good - forwarding no arguments
      #   def method(*args, **kwargs)
      #     super()
      #   end
      class RedundantSuperArguments < Base
        extend AutoCorrector

        DEF_TYPES = %i[def defs].freeze

        MSG = 'Call `super` without arguments and parentheses when the signature is identical.'

        def on_super(super_node)
          def_node = super_node.ancestors.find do |node|
            # You can't implicitly call super when dynamically defining methods
            break if define_method?(node)

            break node if DEF_TYPES.include?(node.type)
          end
          return unless def_node
          return unless arguments_identical?(def_node.arguments.argument_list, super_node.arguments)

          add_offense(super_node) { |corrector| corrector.replace(super_node, 'super') }
        end

        private

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def arguments_identical?(def_args, super_args)
          super_args = preprocess_super_args(super_args)
          return false if def_args.size != super_args.size

          def_args.zip(super_args).each do |def_arg, super_arg|
            next if positional_arg_same?(def_arg, super_arg)
            next if positional_rest_arg_same(def_arg, super_arg)
            next if keyword_arg_same?(def_arg, super_arg)
            next if keyword_rest_arg_same?(def_arg, super_arg)
            next if block_arg_same?(def_arg, super_arg)
            next if forward_arg_same?(def_arg, super_arg)

            return false
          end
          true
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        def positional_arg_same?(def_arg, super_arg)
          return false unless def_arg.arg_type? || def_arg.optarg_type?
          return false unless super_arg.lvar_type?

          def_arg.name == super_arg.children.first
        end

        def positional_rest_arg_same(def_arg, super_arg)
          return false unless def_arg.restarg_type?
          # anon forwarding
          return true if def_arg.name.nil? && super_arg.forwarded_restarg_type?
          return false unless super_arg.splat_type?
          return false unless (lvar_node = super_arg.children.first).lvar_type?

          def_arg.name == lvar_node.children.first
        end

        def keyword_arg_same?(def_arg, super_arg)
          return false unless def_arg.kwarg_type? || def_arg.kwoptarg_type?
          return false unless (pair_node = super_arg).pair_type?
          return false unless (sym_node = pair_node.key).sym_type?
          return false unless (lvar_node = pair_node.value).lvar_type?
          return false unless sym_node.value == lvar_node.children.first

          def_arg.name == sym_node.value
        end

        def keyword_rest_arg_same?(def_arg, super_arg)
          return false unless def_arg.kwrestarg_type?
          # anon forwarding
          return true if def_arg.name.nil? && super_arg.forwarded_kwrestarg_type?
          return false unless super_arg.kwsplat_type?
          return false unless (lvar_node = super_arg.children.first).lvar_type?

          def_arg.name == lvar_node.children.first
        end

        def block_arg_same?(def_arg, super_arg)
          return false unless def_arg.blockarg_type? && super_arg.block_pass_type?
          # anon forwarding
          return true if (block_pass_child = super_arg.children.first).nil? && def_arg.name.nil?

          def_arg.name == block_pass_child.children.first
        end

        def forward_arg_same?(def_arg, super_arg)
          return false unless def_arg.forward_arg_type? && super_arg.forwarded_args_type?

          true
        end

        def define_method?(node)
          return false unless node.block_type?

          child = node.child_nodes.first
          return false unless child.send_type?

          child.method?(:define_method) || child.method?(:define_singleton_method)
        end

        def preprocess_super_args(super_args)
          super_args.map do |node|
            if node.hash_type? && !node.braces?
              node.children
            else
              node
            end
          end.flatten
        end
      end
    end
  end
end
