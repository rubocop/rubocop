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
      #   # bad - race condition with another process may result in an error in `mkdir`
      #   unless Dir.exist?(path)
      #     FileUtils.mkdir(path)
      #   end
      #
      #   # good - atomic and idempotent creation
      #   FileUtils.mkdir_p(path)
      #
      #   # bad - race condition with another process may result in an error in `remove`
      #   if File.exist?(path)
      #     FileUtils.remove(path)
      #   end
      #
      #   # good - atomic and idempotent removal
      #   FileUtils.rm_f(path)
      #
      class NonAtomicFileOperation < Base
        include RangeHelp
        extend AutoCorrector

        MSG_REMOVE_FILE_EXIST_CHECK = 'Remove unnecessary existence check ' \
                                      '`%<receiver>s.%<method_name>s`.'
        MSG_CHANGE_FORCE_METHOD = 'Use atomic file operation method `FileUtils.%<method_name>s`.'
        MAKE_FORCE_METHODS = %i[makedirs mkdir_p mkpath].freeze
        MAKE_METHODS = %i[mkdir].freeze
        REMOVE_FORCE_METHODS = %i[rm_f rm_rf].freeze
        REMOVE_METHODS = %i[remove delete unlink remove_file rm rmdir safe_unlink].freeze
        RECURSIVE_REMOVE_METHODS = %i[remove_dir remove_entry remove_entry_secure].freeze
        RESTRICT_ON_SEND = (
          MAKE_METHODS + MAKE_FORCE_METHODS + REMOVE_METHODS + RECURSIVE_REMOVE_METHODS +
          REMOVE_FORCE_METHODS
        ).freeze

        # @!method send_exist_node(node)
        def_node_search :send_exist_node, <<~PATTERN
          $(send (const {cbase nil?} {:FileTest :File :Dir :Shell}) {:exist? :exists?} ...)
        PATTERN

        # @!method receiver_and_method_name(node)
        def_node_matcher :receiver_and_method_name, <<~PATTERN
          (send (const {cbase nil?} $_) $_ ...)
        PATTERN

        # @!method force?(node)
        def_node_search :force?, <<~PATTERN
          (pair (sym :force) (:true))
        PATTERN

        # @!method explicit_not_force?(node)
        def_node_search :explicit_not_force?, <<~PATTERN
          (pair (sym :force) (:false))
        PATTERN

        def self.autocorrect_incompatible_with
          [Style::MethodCallWithArgsParentheses]
        end

        def on_send(node)
          return unless node.receiver&.const_type?
          return unless if_node_child?(node)
          return if explicit_not_force?(node)
          return unless (exist_node = send_exist_node(node.parent).first)
          return unless exist_node.first_argument == node.first_argument

          register_offense(node, exist_node)
        end

        private

        def if_node_child?(node)
          return false unless (parent = node.parent)

          parent.if_type? && !allowable_use_with_if?(parent)
        end

        def allowable_use_with_if?(if_node)
          if_node.condition.operator_keyword? || if_node.else_branch
        end

        def register_offense(node, exist_node)
          add_offense(node, message: message_change_force_method(node)) unless force_method?(node)

          parent = node.parent
          range = parent.loc.keyword.begin.join(parent.condition.source_range.end)

          add_offense(range, message: message_remove_file_exist_check(exist_node)) do |corrector|
            autocorrect(corrector, node, range) if autocorrectable?(node)
          end
        end

        def message_change_force_method(node)
          format(MSG_CHANGE_FORCE_METHOD, method_name: replacement_method(node))
        end

        def message_remove_file_exist_check(node)
          receiver, method_name = receiver_and_method_name(node)

          format(MSG_REMOVE_FILE_EXIST_CHECK, receiver: receiver, method_name: method_name)
        end

        def autocorrectable?(node)
          parent = node.parent
          return false if parent.elsif?
          return true if parent.modifier_form?
          return true unless code_after_end?(parent)
          return false if !node.parenthesized? || last_heredoc_end_pos(node)

          !processed_source.contains_comment?(body_to_end_range(node))
        end

        def code_after_end?(if_node)
          end_keyword = if_node.loc.end

          !end_keyword.source_line[end_keyword.last_column..].match?(/\A\s*(?:#|\z)/)
        end

        def body_to_end_range(node)
          begin_pos = [node.source_range.end_pos, last_heredoc_end_pos(node)].compact.max

          range_between(begin_pos, node.parent.loc.end.end_pos)
        end

        def last_heredoc_end_pos(node)
          node.each_descendant(:any_str).select(&:heredoc?).map do |heredoc|
            heredoc.loc.heredoc_end.end_pos
          end.max
        end

        def autocorrect(corrector, node, range)
          if_node = node.parent

          corrector.remove(condition_range(if_node, range))
          autocorrect_replace_method(corrector, node)

          if if_node.modifier_form?
            corrector.remove(node.source_range.end.join(if_node.loc.keyword.begin))
          else
            corrector.remove(end_keyword_range(node))
          end
        end

        def condition_range(if_node, range)
          return range unless (separator = if_node.loc.begin)

          range.join(separator)
        end

        def end_keyword_range(node)
          range = body_to_end_range(node)
          return node.parent.loc.end if processed_source.contains_comment?(range)

          range
        end

        def autocorrect_replace_method(corrector, node)
          return if force_method?(node)

          corrector.replace(node.child_nodes.first.loc.name, 'FileUtils')
          corrector.replace(node.loc.selector, replacement_method(node))
          corrector.insert_before(node.last_argument, 'mode: ') if require_mode_keyword?(node)
        end

        def replacement_method(node)
          if MAKE_METHODS.include?(node.method_name)
            'mkdir_p'
          elsif REMOVE_METHODS.include?(node.method_name)
            'rm_f'
          elsif RECURSIVE_REMOVE_METHODS.include?(node.method_name)
            'rm_rf'
          else
            node.method_name
          end
        end

        def force_method?(node)
          force_method_name?(node) || force_option?(node)
        end

        def require_mode_keyword?(node)
          return false unless node.receiver.const_name == 'Dir'

          replacement_method(node) == 'mkdir_p' && node.arguments.length == 2
        end

        def force_option?(node)
          node.arguments.any? { |arg| force?(arg) }
        end

        def force_method_name?(node)
          (MAKE_FORCE_METHODS + REMOVE_FORCE_METHODS).include?(node.method_name)
        end
      end
    end
  end
end
