# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for methods invoked via the `::` operator instead
      # of the `.` operator (like `FileUtils::rmdir` instead of
      # `FileUtils.rmdir`). The `::` operator is conventionally used to
      # reference constants, so using it for method calls can be misleading.
      #
      # @example
      #   # bad
      #   Timeout::timeout(500) { do_something }
      #   FileUtils::rmdir(dir)
      #   Marshal::dump(obj)
      #
      #   # good
      #   Timeout.timeout(500) { do_something }
      #   FileUtils.rmdir(dir)
      #   Marshal.dump(obj)
      #
      class ColonMethodCall < Base
        extend AutoCorrector

        MSG = 'Do not use `::` for method calls.'

        # @!method java_root?(node)
        def_node_matcher :java_root?, <<~PATTERN
          (const nil? :Java)
        PATTERN

        def self.autocorrect_incompatible_with
          [RedundantSelf]
        end

        def on_send(node)
          return unless node.receiver && node.double_colon?
          return if node.camel_case_method?
          # ignore Java interop code like `Java::int` or `Java::com::method`
          return if java_interop?(node)

          add_offense(node.loc.dot) { |corrector| corrector.replace(node.loc.dot, '.') }
        end

        private

        def java_interop?(node)
          receiver = node.receiver
          receiver = receiver.receiver while receiver.respond_to?(:receiver) && receiver.receiver
          java_root?(receiver)
        end
      end
    end
  end
end
