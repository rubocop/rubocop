# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after an attribute accessor or a group of them.
      # `alias` syntax and `alias_method`, `public`, `protected`, and `private` methods are allowed
      # by default. These are customizable with `AllowAliasSyntax` and `AllowedMethods` options.
      #
      # @example
      #   # bad
      #   attr_accessor :foo
      #   def do_something
      #   end
      #
      #   # good
      #   attr_accessor :foo
      #
      #   def do_something
      #   end
      #
      #   # good
      #   attr_accessor :foo
      #   attr_reader :bar
      #   attr_writer :baz
      #   attr :qux
      #
      #   def do_something
      #   end
      #
      # @example AllowAliasSyntax: true (default)
      #   # good
      #   attr_accessor :foo
      #   alias :foo? :foo
      #
      #   def do_something
      #   end
      #
      # @example AllowAliasSyntax: false
      #   # bad
      #   attr_accessor :foo
      #   alias :foo? :foo
      #
      #   def do_something
      #   end
      #
      #   # good
      #   attr_accessor :foo
      #
      #   alias :foo? :foo
      #
      #   def do_something
      #   end
      #
      # @example AllowedMethods: ['private']
      #   # good
      #   attr_accessor :foo
      #   private :foo
      #
      #   def do_something
      #   end
      #
      class EmptyLinesAroundAttributeAccessor < Base
        include RangeHelp
        include AllowedMethods
        extend AutoCorrector

        MSG = 'Add an empty line after attribute accessor.'

        def on_send(node)
          return unless node.attribute_accessor?
          return if next_line_empty?(node.last_line)

          next_line_node = next_line_node(node)
          return unless require_empty_line?(next_line_node)

          add_offense(node) do |corrector|
            range = range_by_whole_lines(node.source_range)

            corrector.insert_after(range, "\n")
          end
        end

        private

        def next_line_empty?(line)
          processed_source[line].blank?
        end

        def require_empty_line?(node)
          return false unless node.respond_to?(:type)

          !allow_alias?(node) && !attribute_or_allowed_method?(node)
        end

        def next_line_node(node)
          return if node.parent.if_type?

          node.right_sibling
        end

        def allow_alias?(node)
          allow_alias_syntax? && node.alias_type?
        end

        def attribute_or_allowed_method?(node)
          return false unless node.send_type?

          node.attribute_accessor? || allowed_method?(node.method_name)
        end

        def allow_alias_syntax?
          cop_config.fetch('AllowAliasSyntax', true)
        end
      end
    end
  end
end
