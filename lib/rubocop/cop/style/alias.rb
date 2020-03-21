# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of either `#alias` or `#alias_method`
      # depending on configuration.
      # It also flags uses of `alias :symbol` rather than `alias bareword`.
      #
      # @example EnforcedStyle: prefer_alias (default)
      #   # bad
      #   alias_method :bar, :foo
      #   alias :bar :foo
      #
      #   # good
      #   alias bar foo
      #
      # @example EnforcedStyle: prefer_alias_method
      #   # bad
      #   alias :bar :foo
      #   alias bar foo
      #
      #   # good
      #   alias_method :bar, :foo
      class Alias < Cop
        include ConfigurableEnforcedStyle

        MSG_ALIAS = 'Use `alias_method` instead of `alias`.'
        MSG_ALIAS_METHOD = 'Use `alias` instead of `alias_method` ' \
                           '%<current>s.'
        MSG_SYMBOL_ARGS  = 'Use `alias %<prefer>s` instead of ' \
                           '`alias %<current>s`.'

        def on_send(node)
          return unless node.command?(:alias_method)
          return unless style == :prefer_alias && alias_keyword_possible?(node)

          msg = format(MSG_ALIAS_METHOD, current: lexical_scope_type(node))
          add_offense(node, location: :selector, message: msg)
        end

        def on_alias(node)
          return unless alias_method_possible?(node)

          if scope_type(node) == :dynamic || style == :prefer_alias_method
            add_offense(node, location: :keyword, message: MSG_ALIAS)
          elsif node.children.none? { |arg| bareword?(arg) }
            add_offense_for_args(node)
          end
        end

        def autocorrect(node)
          if node.send_type?
            correct_alias_method_to_alias(node)
          elsif scope_type(node) == :dynamic || style == :prefer_alias_method
            correct_alias_to_alias_method(node)
          else
            correct_alias_with_symbol_args(node)
          end
        end

        private

        def alias_keyword_possible?(node)
          scope_type(node) != :dynamic && node.arguments.all?(&:sym_type?)
        end

        def alias_method_possible?(node)
          scope_type(node) != :instance_eval &&
            node.children.none?(&:gvar_type?)
        end

        def add_offense_for_args(node)
          existing_args  = node.children.map(&:source).join(' ')
          preferred_args = node.children.map { |a| a.source[1..-1] }.join(' ')
          arg_ranges     = node.children.map(&:source_range)
          msg            = format(MSG_SYMBOL_ARGS,
                                  prefer: preferred_args,
                                  current: existing_args)
          add_offense(node, location: arg_ranges.reduce(&:join), message: msg)
        end

        # In this expression, will `self` be the same as the innermost enclosing
        # class or module block (:lexical)? Or will it be something else
        # (:dynamic)? If we're in an instance_eval block, return that.
        def scope_type(node)
          while (parent = node.parent)
            case parent.type
            when :class, :module
              return :lexical
            when :def, :defs
              return :dynamic
            when :block
              return :instance_eval if parent.method?(:instance_eval)

              return :dynamic
            end
            node = parent
          end
          :lexical
        end

        def lexical_scope_type(node)
          node.each_ancestor(:class, :module) do |ancestor|
            return ancestor.class_type? ? 'in a class body' : 'in a module body'
          end
          'at the top level'
        end

        def bareword?(sym_node)
          !sym_node.source.start_with?(':')
        end

        def correct_alias_method_to_alias(send_node)
          lambda do |corrector|
            new, old = *send_node.arguments
            replacement = "alias #{identifier(new)} #{identifier(old)}"
            corrector.replace(send_node.source_range, replacement)
          end
        end

        def correct_alias_to_alias_method(node)
          lambda do |corrector|
            replacement =
              'alias_method ' \
              ":#{identifier(node.new_identifier)}, " \
              ":#{identifier(node.old_identifier)}"
            corrector.replace(node.source_range, replacement)
          end
        end

        def correct_alias_with_symbol_args(node)
          lambda do |corrector|
            corrector.replace(node.new_identifier.source_range,
                              node.new_identifier.source[1..-1])
            corrector.replace(node.old_identifier.source_range,
                              node.old_identifier.source[1..-1])
          end
        end

        def_node_matcher :identifier, <<~PATTERN
          (sym $_)
        PATTERN
      end
    end
  end
end
