# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `initialize` methods that are redundant.
      #
      # An initializer is redundant if it does not do anything, or if it only
      # calls `super` with the same arguments given to it. If the initializer takes
      # an argument that accepts multiple values (`restarg`, `kwrestarg`, etc.) it
      # will not register an offense, because it allows the initializer to take a different
      # number of arguments as its superclass potentially does.
      #
      # NOTE: If an initializer argument has a default value, RuboCop assumes it
      # to *not* be redundant.
      #
      # NOTE: Empty initializers are registered as offenses, but it is possible
      # to purposely create an empty `initialize` method to override a superclass's
      # initializer.
      #
      # @example
      #   # bad
      #   def initialize
      #   end
      #
      #   # bad
      #   def initialize
      #     super
      #   end
      #
      #   # bad
      #   def initialize(a, b)
      #     super
      #   end
      #
      #   # bad
      #   def initialize(a, b)
      #     super(a, b)
      #   end
      #
      #   # good
      #   def initialize
      #     do_something
      #   end
      #
      #   # good
      #   def initialize
      #     do_something
      #     super
      #   end
      #
      #   # good (different number of parameters)
      #   def initialize(a, b)
      #     super(a)
      #   end
      #
      #   # good (default value)
      #   def initialize(a, b = 5)
      #     super
      #   end
      #
      #   # good (default value)
      #   def initialize(a, b: 5)
      #     super
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(*)
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(**)
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(...)
      #   end
      #
      class RedundantInitialize < Base
        MSG = 'Remove unnecessary `initialize` method.'
        MSG_EMPTY = 'Remove unnecessary empty `initialize` method.'

        # @!method initialize_forwards?(node)
        def_node_matcher :initialize_forwards?, <<~PATTERN
          (def _ (args $arg*) $({super zsuper} ...))
        PATTERN

        def on_def(node)
          return unless node.method?(:initialize)
          return if forwards?(node)

          if node.body.nil?
            add_offense(node, message: MSG_EMPTY)
          else
            return if node.body.begin_type?

            if (args, super_node = initialize_forwards?(node))
              return unless same_args?(super_node, args)

              add_offense(node)
            end
          end
        end

        private

        def forwards?(node)
          node.arguments.each_child_node(:restarg, :kwrestarg, :forward_args, :forward_arg).any?
        end

        def same_args?(super_node, args)
          return true if super_node.zsuper_type?

          args.map(&:name) == super_node.arguments.map { |a| a.children[0] }
        end
      end
    end
  end
end
