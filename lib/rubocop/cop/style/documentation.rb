# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for missing top-level documentation of classes and
      # modules. Classes with no body are exempt from the check and so are
      # namespace modules - modules that have nothing in their bodies except
      # classes, other modules, constant definitions or constant visibility
      # declarations.
      #
      # The documentation requirement is annulled if the class or module has
      # a "#:nodoc:" comment next to it. Likewise, "#:nodoc: all" does the
      # same for all its children.
      #
      # @example
      #   # bad
      #   class Person
      #     # ...
      #   end
      #
      #   module Math
      #   end
      #
      #   # good
      #   # Description/Explanation of Person class
      #   class Person
      #     # ...
      #   end
      #
      #   # allowed
      #     # Class without body
      #     class Person
      #     end
      #
      #     # Namespace - A namespace can be a class or a module
      #     # Containing a class
      #     module Namespace
      #       # Description/Explanation of Person class
      #       class Person
      #         # ...
      #       end
      #     end
      #
      #     # Containing constant visibility declaration
      #     module Namespace
      #       class Private
      #       end
      #
      #       private_constant :Private
      #     end
      #
      #     # Containing constant definition
      #     module Namespace
      #       Public = Class.new
      #     end
      #
      class Documentation < Cop
        include DocumentationComment

        MSG = 'Missing top-level %<type>s documentation comment.'

        def_node_matcher :constant_definition?, '{class module casgn}'
        def_node_search :outer_module, '(const (const nil? _) _)'
        def_node_matcher :constant_visibility_declaration?, <<~PATTERN
          (send nil? {:public_constant :private_constant} ({sym str} _))
        PATTERN

        def on_class(node)
          return unless node.body

          check(node, node.body, :class)
        end

        def on_module(node)
          check(node, node.body, :module)
        end

        private

        def check(node, body, type)
          return if namespace?(body)
          return if documentation_comment?(node) || nodoc_comment?(node)
          return if compact_namespace?(node) &&
                    nodoc_comment?(outer_module(node).first)

          add_offense(node,
                      location: :keyword,
                      message: format(MSG, type: type))
        end

        def namespace?(node)
          return false unless node

          if node.begin_type?
            node.children.all?(&method(:constant_declaration?))
          else
            constant_definition?(node)
          end
        end

        def constant_declaration?(node)
          constant_definition?(node) || constant_visibility_declaration?(node)
        end

        def compact_namespace?(node)
          node.loc.name.source =~ /::/
        end

        # First checks if the :nodoc: comment is associated with the
        # class/module. Unless the element is tagged with :nodoc:, the search
        # proceeds to check its ancestors for :nodoc: all.
        # Note: How end-of-line comments are associated with code changed in
        # parser-2.2.0.4.
        def nodoc_comment?(node, require_all = false)
          return false unless node&.children&.first

          nodoc = nodoc(node)

          return true if same_line?(nodoc, node) && nodoc?(nodoc, require_all)

          nodoc_comment?(node.parent, true)
        end

        def nodoc?(comment, require_all = false)
          comment.text =~ /^#\s*:nodoc:#{"\s+all\s*$" if require_all}/
        end

        def nodoc(node)
          processed_source.ast_with_comments[node.children.first].first
        end
      end
    end
  end
end
