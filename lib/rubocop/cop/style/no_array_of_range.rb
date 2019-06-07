# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Style
      # `[(1..10)]` is semantically the same as `[1..10]` (i.e. an array with 1 range in it.
      # This can lead to some nasty bugs
      #
      # @example
      #   # bad
      #   [1..10]
      #
      #   # bad
      #   [1..(a.length)]
      #
      #   # good
      #   [(1..10)]
      #
      #   # good
      #   [(1..(a.length))]
      #
      class NoArrayOfRange < Cop
        MSG = "Use `[(%<range_exp>s)]` instead of `[%<range_exp>s]` to create an array of a single range. Or you want just a range: `(%<range_exp>s)`".freeze

        def on_array(node)
          array_of_range(node) do |offender|
            add_offense(node, message: message(node))
          end
        end

        def_node_matcher :array_of_range, <<-PATTERN
                         (array (irange _ _))
        PATTERN

        def message(node)
          format(MSG, range_exp: node.children.first.source)
        end
      end
    end
  end
end
