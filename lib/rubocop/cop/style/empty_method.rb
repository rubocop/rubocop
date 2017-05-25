# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the formatting of empty method definitions.
      # By default it enforces empty method definitions to go on a single
      # line (compact style), but it can be configured to enforce the `end`
      # to go on its own line (expanded style).
      #
      # Note: A method definition is not considered empty if it contains
      #       comments.
      #
      # @example
      #
      #   # EnforcedStyle: compact (default)
      #
      #   @bad
      #   def foo(bar)
      #   end
      #
      #   def self.foo(bar)
      #   end
      #
      #   @good
      #   def foo(bar); end
      #
      #   def foo(bar)
      #     # baz
      #   end
      #
      #   def self.foo(bar); end
      #
      #   # EnforcedStyle: expanded
      #
      #   @bad
      #   def foo(bar); end
      #
      #   def self.foo(bar); end
      #
      #   @good
      #   def foo(bar)
      #   end
      #
      #   def self.foo(bar)
      #   end
      class EmptyMethod < Cop
        include OnMethodDef
        include ConfigurableEnforcedStyle

        MSG_COMPACT = 'Put empty method definitions on a single line.'.freeze
        MSG_EXPANDED = 'Put the `end` of empty method definitions on the ' \
                       'next line.'.freeze

        def on_method_def(node, _method_name, _args, body)
          return if body || comment_lines?(node)
          return if compact_style? && compact?(node)
          return if expanded_style? && expanded?(node)

          add_offense(node, node.source_range, message)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, corrected(node))
          end
        end

        def message
          compact_style? ? MSG_COMPACT : MSG_EXPANDED
        end

        def corrected(node)
          method_name, args, _body, scope = method_def_node_parts(node)

          arguments = args.source unless args.children.empty?
          joint = compact_style? ? '; ' : "\n"
          scope = scope ? 'self.' : ''

          ["def #{scope}#{method_name}#{arguments}", 'end'].join(joint)
        end

        def comment_lines?(node)
          processed_source[line_range(node)].any? { |line| comment_line?(line) }
        end

        def compact?(node)
          node.single_line?
        end

        def expanded?(node)
          node.multiline?
        end

        def compact_style?
          style == :compact
        end

        def expanded_style?
          style == :expanded
        end
      end
    end
  end
end
