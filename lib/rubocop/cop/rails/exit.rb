# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces that 'exit' calls are not used within a rails app.
      # Valid options are instead to raise an error, break, return or some
      # other form of stopping execution of current request.
      #
      # There are two obvious cases where 'exit' is particularly harmful:
      #
      # - Usage in library code for your application. Even though rails will
      # rescue from a SystemExit and continue on, unit testing that library
      # code will result in specs exiting (potentially silently if exit(0)
      # is used.)
      # - Usage in application code outside of the web process could result in
      # the program exiting, which could result in the code failing to run and
      # do its job.
      class Exit < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Do not use `exit` in Rails applications.'.freeze
        TARGET_METHODS = %i(exit exit!).freeze
        EXPLICIT_RECEIVERS = %i(Kernel Process).freeze

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        private

        def offending_node?(node)
          right_method_name?(node.method_name) &&
            right_argument_count?(node.arguments) &&
            right_receiver?(node.receiver)
        end

        def right_method_name?(method_name)
          TARGET_METHODS.include?(method_name)
        end

        # More than 1 argument likely means it is a different
        # `exit` implementation than the one we are preventing.
        def right_argument_count?(arg_nodes)
          arg_nodes.size <= 1
        end

        # Only register if exit is being called explicitly on
        # Kernel or Process or if receiver node is nil for plain
        # `exit` calls.
        def right_receiver?(receiver_node)
          return true unless receiver_node

          _a, receiver_node_class, _c = *receiver_node

          EXPLICIT_RECEIVERS.include?(receiver_node_class)
        end
      end
    end
  end
end
