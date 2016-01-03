# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop finds uses of `alias` where `alias_method` would be more
      # appropriate (or is simply preferred due to configuration), and vice
      # versa.
      # It also finds uses of `alias :symbol` rather than `alias bareword`.
      class Alias < Cop
        include ConfigurableEnforcedStyle

        MSG_ALIAS = 'Use `alias_method` instead of `alias`.'
        MSG_ALIAS_METHOD = 'Use `alias` instead of `alias_method` %s.'
        MSG_SYMBOL_ARGS  = 'Use `alias %s` instead of `alias %s`.'

        def on_send(node)
          return unless node.method_name == :alias_method && node.receiver.nil?
          return if style == :prefer_alias_method
          return if scope_type(node) == :dynamic

          msg = format(MSG_ALIAS_METHOD, lexical_scope_type(node))
          add_offense(node, :selector, msg)
        end

        def on_alias(node)
          # alias_method can't be used with global variables
          return if node.children.any?(&:gvar_type?)

          if scope_type(node) == :dynamic || style == :prefer_alias_method
            add_offense(node, :keyword, MSG_ALIAS)
          elsif node.children.none? { |arg| bareword?(arg) }
            existing_args  = node.children.map(&:source).join(' ')
            preferred_args = node.children.map { |a| a.source[1..-1] }.join(' ')
            arg_ranges     = node.children.map(&:source_range)
            msg            = format(MSG_SYMBOL_ARGS, preferred_args,
                                    existing_args)
            add_offense(node, arg_ranges.reduce(&:join), msg)
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

        # In this expression, will `self` be the same as the innermost enclosing
        # class or module block (:lexical)? Or will it be something else
        # (:dynamic)?
        def scope_type(node)
          while (parent = node.parent)
            case parent.type
            when :class, :module
              return :lexical
            when :def, :defs, :block
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
          sym_node.source[0] != ':'
        end

        def correct_alias_method_to_alias(node)
          lambda do |corrector|
            new, old = *node.method_args
            replacement = "alias #{new.children.first} #{old.children.first}"
            corrector.replace(node.source_range, replacement)
          end
        end

        def correct_alias_to_alias_method(node)
          lambda do |corrector|
            new, old = *node
            replacement = "alias_method :#{new.children.first}, " \
                          ":#{old.children.first}"
            corrector.replace(node.source_range, replacement)
          end
        end

        def correct_alias_with_symbol_args(node)
          lambda do |corrector|
            new, old = *node
            corrector.replace(new.source_range, new.children.first.to_s)
            corrector.replace(old.source_range, old.children.first.to_s)
          end
        end
      end
    end
  end
end
