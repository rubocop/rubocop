# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for arrays that are not explicitly initialized with
      # brackets. Exceptions are allowed for implicit arrays of exceptions in a
      # rescue block and for the result of a splat operator.
      #
      # @example
      #   # bad
      #   a = 1, 2, 3
      #
      #   # good
      #   a = [1, 2, 3]
      #
      # @example
      #
      #   # good
      #   def foo
      #     some_scary_method
      #   rescue SomeException, SomeOtherException
      #     some_cleanup
      #   end
      #
      # @example
      #
      #   # good
      #   x = *y
      class ImplicitArray < Cop
        MSG = 'Explicitly initialize arrays with `[` and `]`.'.freeze

        def on_array(node)
          return if node.parent && node.parent.resbody_type?
          return if node.descendants.any?(&:splat_type?)
          add_offense(node) unless node.bracketed?
        end

        def autocorrect(node)
          lambda do |corrector|
            range = node.source_range
            corrector.insert_before(range, '[')
            corrector.insert_after(range, ']')
          end
        end
      end
    end
  end
end
