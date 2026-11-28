# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of either `#alias` or `#alias_method`
      # depending on configuration. Consistent use of one or the
      # other prevents confusion about their different semantics
      # (e.g., `alias` is resolved at parse time, while `alias_method`
      # is resolved at runtime).
      # It also flags uses of `alias :symbol` rather than `alias bareword`.
      #
      # However, it will always enforce `alias_method` when `alias` is used
      # in an instance method definition and in a singleton method definition.
      # If used in a block, always enforce `alias_method`
      # unless it is an `instance_eval` block.
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
      #
      class Alias < Base
        include ConfigurableEnforcedStyle
        include RescueNode
        extend AutoCorrector

        MSG_ALIAS = 'Use `alias_method` instead of `alias`.'
        MSG_ALIAS_METHOD = 'Use `alias` instead of `alias_method` %<current>s.'
        MSG_SYMBOL_ARGS  = 'Use `alias %<prefer>s` instead of `alias %<current>s`.'

        RESTRICT_ON_SEND = %i[alias_method].freeze
        SCOPE_AND_LOOP_TYPES = %i[
          class module sclass block numblock itblock while until while_post until_post for
        ].freeze

        def on_send(node)
          return unless node.command?(:alias_method)
          return unless style == :prefer_alias && alias_keyword_possible?(node)
          return unless node.arguments.count == 2
          return unless statement?(node)

          msg = format(MSG_ALIAS_METHOD, current: lexical_scope_type(node))
          add_offense(node.loc.selector, message: msg) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def on_alias(node)
          return unless alias_method_possible?(node)

          if scope_type(node) == :dynamic || style == :prefer_alias_method
            add_offense(node.loc.keyword, message: MSG_ALIAS) do |corrector|
              autocorrect(corrector, node)
            end
          elsif node.children.all? { |arg| !bareword?(arg) && bareword_symbol?(arg) }
            add_offense_for_args(node) { |corrector| autocorrect(corrector, node) }
          end
        end

        private

        def autocorrect(corrector, node)
          if node.send_type?
            correct_alias_method_to_alias(corrector, node)
          elsif scope_type(node) == :dynamic || style == :prefer_alias_method
            correct_alias_to_alias_method(corrector, node)
          else
            correct_alias_with_symbol_args(corrector, node)
          end
        end

        def alias_keyword_possible?(node)
          scope_type(node) != :dynamic && node.arguments.all?(&:sym_type?)
        end

        def statement?(node)
          parent = node.parent
          return true unless parent
          return true if value_discarded?(parent, node)

          value_passed_through?(parent, node) && statement?(parent)
        end

        def value_discarded?(parent, node)
          case parent.type
          when :begin, :kwbegin
            !parent.children.last.equal?(node)
          when *SCOPE_AND_LOOP_TYPES
            parent.body.equal?(node)
          when :ensure
            parent.branch.equal?(node)
          else
            parent.type?(:preexe, :postexe)
          end
        end

        def value_passed_through?(parent, node)
          case parent.type
          when :begin, :kwbegin, :ensure
            true
          when :rescue
            !rescue_modifier?(node)
          when :if
            !parent.ternary? && !parent.condition.equal?(node)
          when :case, :case_match
            !parent.condition.equal?(node)
          when :when, :in_pattern, :resbody
            parent.body.equal?(node)
          else
            false
          end
        end

        def alias_method_possible?(node)
          scope_type(node) != :instance_eval &&
            node.children.none?(&:gvar_type?) &&
            node.each_ancestor(:def).none?
        end

        def add_offense_for_args(node, &block)
          existing_args  = node.children.map(&:source).join(' ')
          preferred_args = node.children.map { |node| bareword_for(node) }.join(' ')
          arg_ranges     = node.children.map(&:source_range)
          msg            = format(MSG_SYMBOL_ARGS, prefer: preferred_args, current: existing_args)
          add_offense(arg_ranges.reduce(&:join), message: msg, &block)
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
            when :block, :numblock, :itblock
              return :instance_eval if parent.method?(:instance_eval)

              return :dynamic
            end
            node = parent
          end
          :lexical
        end

        def lexical_scope_type(node)
          ancestor = node.each_ancestor(:class, :module).first
          if ancestor.nil?
            'at the top level'
          elsif ancestor.class_type?
            'in a class body'
          else
            'in a module body'
          end
        end

        def bareword?(sym_node)
          !sym_node.source.start_with?(':') || sym_node.dsym_type?
        end

        def bareword_symbol?(sym_node)
          return false unless sym_node.sym_type?

          value = sym_node.value.to_s
          return true if value.match?(/\A[A-Za-z_]\w*[?!=]?\z/)

          !sym_node.source.start_with?(':"', ":'") && !value.start_with?('@', '$')
        end

        def correct_alias_method_to_alias(corrector, send_node)
          new, old = *send_node.arguments
          replacement = "alias #{identifier(new)} #{identifier(old)}"

          corrector.replace(send_node, replacement)
        end

        def correct_alias_to_alias_method(corrector, node)
          replacement =
            "alias_method #{identifier(node.new_identifier)}, #{identifier(node.old_identifier)}"

          corrector.replace(node, replacement)
        end

        def correct_alias_with_symbol_args(corrector, node)
          corrector.replace(node.new_identifier, bareword_for(node.new_identifier))
          corrector.replace(node.old_identifier, bareword_for(node.old_identifier))
        end

        def identifier(node)
          if bareword_symbol?(node)
            ":#{node.children.first}"
          else
            node.source
          end
        end

        def bareword_for(sym_node)
          sym_node.value.to_s
        end
      end
    end
  end
end
