# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for useless method definitions, specifically: empty constructors
      # and methods just delegating to `super`.
      #
      # This cop is marked as unsafe as it can trigger false positives for cases when
      # an empty constructor just overrides the parent constructor, which is bad anyway.
      #
      # @example
      #   # bad
      #   def initialize
      #     super
      #   end
      #
      #   def method
      #     super
      #   end
      #
      #   # good - with default arguments
      #   def initialize(x = Object.new)
      #     super
      #   end
      #
      #   # good
      #   def initialize
      #     super
      #     initialize_internals
      #   end
      #
      #   def method(*args)
      #     super(:extra_arg, *args)
      #   end
      #
      class UselessMethodDefinition < Base
        extend AutoCorrector

        MSG = 'Useless method definition detected.'

        def on_def(node)
          return if optional_args?(node)
          return unless delegating?(node.body, node)

          add_offense(node) { |corrector| corrector.remove(node) }
        end
        alias on_defs on_def

        private

        def optional_args?(node)
          node.arguments.any? { |arg| arg.optarg_type? || arg.kwoptarg_type? }
        end

        def delegating?(node, def_node)
          if node&.zsuper_type?
            true
          elsif node&.super_type?
            node.arguments.map(&:source) == def_node.arguments.map(&:source)
          else
            false
          end
        end
      end
    end
  end
end
