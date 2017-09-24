# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for missing top-level documentation of
      # classes and modules. Classes with no body are exempt from the
      # check and so are namespace modules - modules that have nothing in
      # their bodies except classes, other modules, or constant definitions.
      #
      # The documentation requirement is annulled if the class or module has
      # a "#:nodoc:" comment next to it. Likewise, "#:nodoc: all" does the
      # same for all its children.
      class Documentation < Cop
        include DocumentationComment

        MSG = 'Missing top-level %s documentation comment.'.freeze

        def_node_matcher :constant_definition?, '{class module casgn}'

        def on_class(node)
          _, _, body = *node

          return unless body

          check(node, body, :class)
        end

        def on_module(node)
          _, body = *node

          check(node, body, :module)
        end

        private

        def check(node, body, type)
          return if namespace?(body)
          return if documentation_comment?(node) || nodoc_comment?(node)

          add_offense(node, location: :keyword, message: format(MSG, type))
        end

        def namespace?(node)
          return false unless node

          if node.begin_type?
            node.children.all? { |child| constant_definition?(child) }
          else
            constant_definition?(node)
          end
        end

        # First checks if the :nodoc: comment is associated with the
        # class/module. Unless the element is tagged with :nodoc:, the search
        # proceeds to check its ancestors for :nodoc: all.
        # Note: How end-of-line comments are associated with code changed in
        # parser-2.2.0.4.
        def nodoc_comment?(node, require_all = false)
          return false unless node && node.children.first

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
