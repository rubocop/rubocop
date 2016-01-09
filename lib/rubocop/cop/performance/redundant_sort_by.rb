# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `sort_by { ... }` can be replaced by
      # `sort`.
      #
      # @example
      #   @bad
      #   array.sort_by { |x| x }
      #   array.sort_by do |var|
      #     var
      #   end
      #
      #   @good
      #   array.sort
      class RedundantSortBy < Cop
        MSG = 'Use `sort` instead of `sort_by { |%s| %s }`.'.freeze

        def_node_matcher :redundant_sort_by, <<-END
          (block $(send _ :sort_by) (args (arg $_x)) (lvar _x))
        END

        def on_block(node)
          redundant_sort_by(node) do |send, var_name|
            range = Parser::Source::Range.new(node.source_range.source_buffer,
                                              send.loc.selector.begin_pos,
                                              node.loc.end.end_pos)
            add_offense(node, range, format(MSG, var_name, var_name))
          end
        end

        def autocorrect(node)
          send, = *node
          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            send.loc.selector.begin_pos,
                                            node.loc.end.end_pos)
          ->(corrector) { corrector.replace(range, 'sort') }
        end
      end
    end
  end
end
