# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # When passing an existing hash as keyword arguments, add additional arguments
      # directly rather than using `merge`.
      #
      # @example
      #   # bad
      #   some_method(**opts.merge(foo: true))
      #   some_method(**opts.merge(other_opts))
      #
      #   # good
      #   some_method(**opts, foo: true)
      #   some_method(**opts, **other_opts)
      #
      class KeywordArgumentsMerging < Base
        extend AutoCorrector

        MSG = 'Add additional arguments directly rather than using `merge`.'

        # @!method merge_kwargs?(node)
        def_node_matcher :merge_kwargs?, <<~PATTERN
          (send _ _
            ...
            (hash
              (kwsplat
                $(send $_ :merge $_))
              ...))
        PATTERN

        def on_kwsplat(node)
          return unless (ancestor = node.parent&.parent)

          merge_kwargs?(ancestor) do |merge_node, hash_node, other_hash_node|
            add_offense(merge_node) do |corrector|
              autocorrect(corrector, node, hash_node, other_hash_node)
            end
          end
        end

        private

        def autocorrect(corrector, kwsplat_node, hash_node, other_hash_node)
          other_hash_node_replacement =
            if other_hash_node.hash_type?
              if other_hash_node.braces?
                other_hash_node.source[1...-1]
              else
                other_hash_node.source
              end
            else
              "**#{other_hash_node.source}"
            end

          corrector.replace(kwsplat_node, "**#{hash_node.source}, #{other_hash_node_replacement}")
        end
      end
    end
  end
end
