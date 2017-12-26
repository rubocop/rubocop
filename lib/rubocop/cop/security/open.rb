# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of `Kernel#open`.
      # `Kernel#open` enables not only file access but also process invocation
      # by prefixing a pipe symbol (e.g., `open("| ls")`).  So, it may lead to
      # a serious security risk by using variable input to the argument of
      # `Kernel#open`.  It would be better to use `File.open` or `IO.popen`
      # explicitly.
      #
      # @example
      #   # bad
      #   open(something)
      #
      #   # good
      #   File.open(something)
      #   IO.popen(something)
      class Open < Cop
        MSG = 'The use of `Kernel#open` is a serious security risk.'.freeze

        def_node_matcher :open?, <<-PATTERN
          (send nil? :open $!str ...)
        PATTERN

        def safe?(node)
          if node.str_type?
            !node.str_content.empty? && !node.str_content.start_with?('|')
          elsif node.dstr_type?
            safe?(node.child_nodes.first)
          elsif node.send_type? && node.method_name == :+
            safe?(node.child_nodes.first)
          else
            false
          end
        end

        def on_send(node)
          open?(node) do |code|
            return if safe?(code)
            add_offense(node, location: :selector)
          end
        end
      end
    end
  end
end
