# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for instance variables used in classes outside of the
      # initializer. It encourages using attr_reader or attr_accessor to set
      # up safer methods to read from or write to your instance variable.
      #
      # In Rails projects, it's probably good to exclude controllers, jobs,
      # and mailers straightaway.
      #
      # ```yaml
      # Exclude:
      #   - "app/controllers/**/*"
      #   - "app/jobs/**/*"
      #   - "app/mailers/**/*"
      # ```
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     def initialize
      #       @foo = "bar"
      #     end
      #
      #     def instance_method
      #       @foo
      #     end
      #   end
      #
      #   # bad
      #   class Foo
      #     def initialize
      #       @foo = "bar"
      #     end
      #
      #     def instance_method
      #       @foo = "baz"
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     attr_reader :foo
      #
      #     def initialize
      #       @foo = "bar"
      #     end
      #
      #     def instance_method
      #       foo
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     attr_accessor :foo
      #
      #     def initialize
      #       @foo = "bar"
      #     end
      #
      #     def instance_method
      #       foo = "baz"
      #     end
      #   end
      #
      class InstanceVarsInClass < Cop
        MSG = 'Outside of the initializer, use an `attr_%<type>s ' \
              ':%<var_name>s` instead of `%<usage>s`.'.freeze

        def on_ivar(node)
          return if not_an_offense?(node)

          variable_name = extract_variable_name(node)

          case node.type
          when :ivasgn
            usage = "@#{variable_name}="
            type = 'accessor'
          when :ivar
            usage = "@#{variable_name}"
            type = 'reader'
          else
            return
          end

          add_offense(node, message: format_message(type, usage, variable_name))
        end
        alias on_ivasgn on_ivar

        private

        def extract_variable_name(node)
          var_name, = *node
          var_name.to_s[1..-1]
        end

        def format_message(type, usage, var_name)
          format(MSG, type: type, var_name: var_name, usage: usage)
        end

        def not_an_offense?(node)
          !in_class?(node) || in_initializer?(node) || in_memoize?(node)
        end

        def in_class?(node)
          node.each_ancestor(:class, :module).any?
        end

        def in_initializer?(node)
          node.each_ancestor(:def).any? do |n|
            method, = *n
            method == :initialize
          end
        end

        def in_memoize?(node)
          node.parent.or_asgn_type?
        end
      end
    end
  end
end
