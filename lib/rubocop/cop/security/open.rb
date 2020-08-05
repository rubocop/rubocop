# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of `Kernel#open`.
      #
      # `Kernel#open` enables not only file access but also process invocation
      # by prefixing a pipe symbol (e.g., `open("| ls")`). So, it may lead to
      # a serious security risk by using variable input to the argument of
      # `Kernel#open`. It would be better to use `File.open`, `IO.popen` or
      # `URI#open` explicitly.
      #
      # @example
      #   # bad
      #   open(something)
      #
      #   # good
      #   File.open(something)
      #   IO.popen(something)
      #   URI.parse(something).open
      class Open < Base
        MSG = 'The use of `Kernel#open` is a serious security risk.'

        def_node_matcher :open?, <<~PATTERN
          (send nil? :open $!str ...)
        PATTERN

        def on_send(node)
          open?(node) do |code|
            return if safe?(code)

            add_offense(node.loc.selector)
          end
        end

        private

        def safe?(node)
          if simple_string?(node)
            safe_argument?(node.str_content)
          elsif composite_string?(node)
            safe?(node.children.first)
          else
            false
          end
        end

        def safe_argument?(argument)
          !argument.empty? && !argument.start_with?('|')
        end

        def simple_string?(node)
          node.str_type?
        end

        def composite_string?(node)
          interpolated_string?(node) || concatenated_string?(node)
        end

        def interpolated_string?(node)
          node.dstr_type?
        end

        def concatenated_string?(node)
          node.send_type? && node.method?(:+) && node.receiver.str_type?
        end
      end
    end
  end
end
