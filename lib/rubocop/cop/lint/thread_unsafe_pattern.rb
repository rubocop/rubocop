# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for thread-unsafe patterns inside `Thread.new`,
      # `Thread.start`, `Thread.fork`, and `Ractor.new` blocks.
      #
      # Class variables (`@@var`) are shared across all instances and
      # all threads. Accessing them inside a thread block without
      # synchronization is a race condition. Global variable mutation
      # (`$var = ...`) inside thread blocks introduces shared mutable
      # state that is visible to all threads.
      #
      # This cop only flags these patterns when they appear inside
      # thread or ractor blocks, where the concurrency risk is
      # concrete rather than hypothetical.
      #
      # @example
      #   # bad
      #   Thread.new { @@count += 1 }
      #
      #   # bad
      #   Thread.new do
      #     @@count = 0
      #   end
      #
      #   # bad
      #   Thread.start { $output = StringIO.new }
      #
      #   # bad
      #   Ractor.new { @@count }
      #
      #   # bad - nested blocks inside a thread block
      #   Thread.new do
      #     items.each { @@count += 1 }
      #   end
      #
      #   # good - class variable access outside a thread block
      #   @@count = 0
      #
      #   # good - global variable mutation outside a thread block
      #   $stdout = StringIO.new
      #
      #   # good - use thread-safe alternatives
      #   mutex = Mutex.new
      #   Thread.new { mutex.synchronize { @count += 1 } }
      #
      # @example AllowedGlobalVariables: ['$stdout', '$stderr']
      #   # good - these global variable mutations are allowed
      #   Thread.new { $stdout = StringIO.new }
      #
      class ThreadUnsafePattern < Base
        CLASS_VARIABLE_MSG = 'Class variable `%<variable>s` is thread-unsafe. ' \
                             'Consider using a class instance variable, ' \
                             'a mutex, or `Thread::local` instead.'
        GLOBAL_VARIABLE_MSG = 'Mutating global variable `%<variable>s` is thread-unsafe.'

        # @!method thread_or_ractor_block?(node)
        def_node_matcher :thread_or_ractor_block?, <<~PATTERN
          (any_block
            (send (const nil? {:Thread :Ractor})
                  {:new :start :fork} ...)
            ...)
        PATTERN

        def on_cvar(node)
          return unless inside_thread_block?(node)

          add_offense(node, message: format(CLASS_VARIABLE_MSG, variable: node.name))
        end

        def on_cvasgn(node)
          return unless inside_thread_block?(node)

          add_offense(node.loc.name, message: format(CLASS_VARIABLE_MSG, variable: node.name))
        end

        def on_gvasgn(node)
          return unless inside_thread_block?(node)
          return if allowed_global_variable?(node.name)

          add_offense(node.loc.name, message: format(GLOBAL_VARIABLE_MSG, variable: node.name))
        end

        private

        def inside_thread_block?(node)
          node.each_ancestor(:any_block).any? { |block_node| thread_or_ractor_block?(block_node) }
        end

        def allowed_global_variable?(name)
          allowed_global_variables.include?(name.to_s)
        end

        def allowed_global_variables
          @allowed_global_variables ||= cop_config.fetch('AllowedGlobalVariables', []).to_set
        end
      end
    end
  end
end
