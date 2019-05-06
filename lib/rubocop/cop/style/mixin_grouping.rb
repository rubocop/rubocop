# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for grouping of mixins in `class` and `module` bodies.
      # By default it enforces mixins to be placed in separate declarations,
      # but it can be configured to enforce grouping them in one declaration.
      #
      # @example EnforcedStyle: separated (default)
      #   # bad
      #   class Foo
      #     include Bar, Qox
      #   end
      #
      #   # good
      #   class Foo
      #     include Qox
      #     include Bar
      #   end
      #
      # @example EnforcedStyle: grouped
      #   # bad
      #   class Foo
      #     extend Bar
      #     extend Qox
      #   end
      #
      #   # good
      #   class Foo
      #     extend Qox, Bar
      #   end
      class MixinGrouping < Cop
        include ConfigurableEnforcedStyle

        MIXIN_METHODS = %i[extend include prepend].freeze
        MSG = 'Put `%<mixin>s` mixins in %<suffix>s.'

        def on_class(node)
          begin_node = node.child_nodes.find(&:begin_type?) || node
          begin_node.each_child_node(:send).select(&:macro?).each do |macro|
            next unless MIXIN_METHODS.include?(macro.method_name)

            check(macro)
          end
        end

        alias on_module on_class

        def autocorrect(node)
          range = node.loc.expression
          if separated_style?
            correction = separate_mixins(node)
          else
            mixins = sibling_mixins(node)
            if node == mixins.first
              correction = group_mixins(node, mixins)
            else
              range = range_to_remove_for_subsequent_mixin(mixins, node)
              correction = ''
            end
          end

          ->(corrector) { corrector.replace(range, correction) }
        end

        private

        def range_to_remove_for_subsequent_mixin(mixins, node)
          range = node.loc.expression
          prev_mixin = mixins.each_cons(2) { |m, n| break m if n == node }
          between = prev_mixin.loc.expression.end
                              .join(range.begin)
          # if separated from previous mixin with only whitespace?
          if between.source !~ /\S/
            range = range.join(between) # then remove that too
          end
          range
        end

        def check(send_node)
          if separated_style?
            check_separated_style(send_node)
          else
            check_grouped_style(send_node)
          end
        end

        def check_grouped_style(send_node)
          return if sibling_mixins(send_node).size == 1

          add_offense(send_node)
        end

        def check_separated_style(send_node)
          return if send_node.arguments.one?

          add_offense(send_node)
        end

        def sibling_mixins(send_node)
          siblings = send_node.parent.each_child_node(:send)
                              .select(&:macro?)

          siblings.select do |sibling_node|
            sibling_node.method_name == send_node.method_name
          end
        end

        def message(send_node)
          suffix =
            separated_style? ? 'separate statements' : 'a single statement'

          format(MSG, mixin: send_node.method_name, suffix: suffix)
        end

        def grouped_style?
          style == :grouped
        end

        def separated_style?
          style == :separated
        end

        def separate_mixins(node)
          arguments = node.arguments.reverse
          mixins = ["#{node.method_name} #{arguments.first.source}"]

          arguments[1..-1].inject(mixins) do |replacement, arg|
            replacement << "#{indent(node)}#{node.method_name} #{arg.source}"
          end.join("\n")
        end

        def group_mixins(node, mixins)
          mixin_names = mixins.reverse.flat_map do |mixin|
            mixin.arguments.map(&:source)
          end

          "#{node.method_name} #{mixin_names.join(', ')}"
        end

        def indent(node)
          ' ' * node.loc.column
        end
      end
    end
  end
end
