# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for non-atomic file operation.
      # And then replace it with a nearly equivalent and atomic method.
      #
      # These can cause problems that are difficult to reproduce,
      # especially in cases of frequent file operations in parallel,
      # such as test runs with parallel_rspec.
      #
      # For examples: creating a directory if there is none, has the following problems
      #
      # An exception occurs when the directory didn't exist at the time of `exist?`,
      # but someone else created it before `mkdir` was executed.
      #
      # Subsequent processes are executed without the directory that should be there
      # when the directory existed at the time of `exist?`,
      # but someone else deleted it shortly afterwards.
      #
      # @safety
      #   This cop is unsafe, because autocorrection change to atomic processing.
      #   The atomic processing of the replacement destination is not guaranteed
      #   to be strictly equivalent to that before the replacement.
      #
      # @example
      #   # bad
      #   unless FileTest.exist?(path)
      #     FileUtils.makedirs(path)
      #   end
      #
      #   if FileTest.exist?(path)
      #     FileUtils.remove(path)
      #   end
      #
      #   # good
      #   FileUtils.mkdir_p(path)
      #
      #   FileUtils.rm_rf(path)
      #
      class NonAtomicFileOperation < Base
        extend AutoCorrector
        include Alignment
        include RangeHelp

        MSG = 'Remove unnecessary existence checks `%<receiver>s.%<method_name>s`.'
        MAKE_METHODS = %i[makedirs mkdir mkdir_p mkpath].freeze
        REMOVE_METHODS = %i[remove remove_dir remove_entry remove_entry_secure delete unlink
                            remove_file rm rm_f rm_r rm_rf rmdir rmtree safe_unlink].freeze
        RESTRICT_ON_SEND = (MAKE_METHODS + REMOVE_METHODS).freeze

        # @!method send_exist_node(node)
        def_node_search :send_exist_node, <<-PATTERN
          $(send (const nil? {:FileTest :File :Dir :Shell}) {:exist? :exists?} ...)
        PATTERN

        # @!method receiver_and_method_name(node)
        def_node_matcher :receiver_and_method_name, <<-PATTERN
          (send (const nil? $_) $_ ...)
        PATTERN

        # @!method force?(node)
        def_node_search :force?, <<~PATTERN
          (pair (sym :force) (:true))
        PATTERN

        # @!method explicit_not_force?(node)
        def_node_search :explicit_not_force?, <<~PATTERN
          (pair (sym :force) (:false))
        PATTERN

        def on_send(node)
          return unless node.parent&.if_type?
          return if node.parent.else_branch
          return if explicit_not_force?(node)
          return unless (exist_node = send_exist_node(node.parent).first)
          return unless exist_node.first_argument == node.first_argument

          offense(node, exist_node)
        end

        private

        def offense(node, exist_node)
          range = range_between(node.parent.loc.keyword.begin_pos,
                                exist_node.loc.expression.end_pos)

          add_offense(range, message: message(exist_node)) do |corrector|
            autocorrect(corrector, node, range)
          end
        end

        def message(node)
          receiver, method_name = receiver_and_method_name(node)
          format(MSG, receiver: receiver, method_name: method_name)
        end

        def autocorrect(corrector, node, range)
          corrector.remove(range)
          corrector.replace(node.child_nodes.first.loc.name, 'FileUtils')
          corrector.replace(node.loc.selector, replacement_method(node))
          corrector.remove(node.parent.loc.end) if node.parent.multiline?
        end

        def replacement_method(node)
          return node.method_name if force_option?(node)

          if MAKE_METHODS.include?(node.method_name)
            'mkdir_p'
          elsif REMOVE_METHODS.include?(node.method_name)
            'rm_rf'
          end
        end

        def force_option?(node)
          node.arguments.any? { |arg| force?(arg) }
        end
      end
    end
  end
end
