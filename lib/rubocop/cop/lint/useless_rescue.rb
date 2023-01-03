# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for useless `rescue`s, which only reraise rescued exceptions.
      #
      # @example
      #   # bad
      #   def foo
      #     do_something
      #   rescue
      #     raise
      #   end
      #
      #   # bad
      #   def foo
      #     do_something
      #   rescue => e
      #     raise # or 'raise e', or 'raise $!', or 'raise $ERROR_INFO'
      #   end
      #
      #   # good
      #   def foo
      #     do_something
      #   rescue
      #     do_cleanup
      #     raise
      #   end
      #
      #   # bad (latest rescue)
      #   def foo
      #     do_something
      #   rescue ArgumentError
      #     # noop
      #   rescue
      #     raise
      #   end
      #
      #   # good (not the latest rescue)
      #   def foo
      #     do_something
      #   rescue ArgumentError
      #     raise
      #   rescue
      #     # noop
      #   end
      #
      class UselessRescue < Base
        MSG = 'Useless `rescue` detected.'

        def on_rescue(node)
          resbody_node = node.resbody_branches.last
          add_offense(resbody_node) if only_reraising?(resbody_node)
        end

        private

        def only_reraising?(resbody_node)
          body = resbody_node.body
          return false if body.nil? || !body.send_type? || !body.method?(:raise)
          return true unless body.arguments?
          return false if body.arguments.size > 1

          exception_name = body.first_argument.source
          [resbody_node.exception_variable&.source, '$!', '$ERROR_INFO'].include?(exception_name)
        end
      end
    end
  end
end
