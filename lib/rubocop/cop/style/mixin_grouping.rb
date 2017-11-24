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
        MSG = 'Put `%s` mixins in %s.'.freeze

        def on_send(node)
          return unless node.macro? && MIXIN_METHODS.include?(node.method_name)

          check(node)
        end

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

          format(MSG, send_node.method_name, suffix)
        end

        def grouped_style?
          style == :grouped
        end

        def separated_style?
          style == :separated
        end

        def separate_mixins(node)
          _receiver, mixin, *args = *node
          args.reverse!
          first_mixin = String.new("#{mixin} #{args.first.source}")

          args[1..-1].inject(first_mixin) do |replacement, arg|
            replacement << "\n#{indent(node)}#{mixin} #{arg.source}"
          end
        end

        def group_mixins(node, mixins)
          _receiver, mixin, *_args = *node
          all_mixin_arguments = mixins.reverse.flat_map do |m|
            m.arguments.map(&:source)
          end

          "#{mixin} #{all_mixin_arguments.join(', ')}"
        end

        def indent(node)
          ' ' * node.loc.column
        end
      end
    end
  end
end
