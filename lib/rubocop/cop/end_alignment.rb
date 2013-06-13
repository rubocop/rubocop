# encoding: utf-8

module Rubocop
  module Cop
    class EndAlignment < Cop
      MSG = 'end at %d, %d is not aligned with %s at %d, %d'

      def on_def(node)
        check(node)
        super
      end

      def on_defs(node)
        check(node)
        super
      end

      def on_class(node)
        check(node)
        super
      end

      def on_module(node)
        check(node)
        super
      end

# def on_block(node)
#   start_loc = node.loc.expression
#   end_loc = node.loc.end

#   if start_loc.line != end_loc.line && start_loc.column != end_loc.column
#     add_offence(:warning,
#                 end_loc.expression,
#                 sprintf(MSG, end_loc.line, end_loc.column,
#                         start_loc.source.lines.to_a.first.chomp,
#                         start_loc.line, start_loc.column))
#   end

#   super
# end

      def on_if(node)
        check(node) if node.loc.respond_to?(:end)
        super
      end

      def on_while(node)
        check(node)
        super
      end

      def on_until(node)
        check(node)
        super
      end

      private

      def check(node)
        # discard modifier forms of if/while/until
        return unless node.loc.end

        kw_loc = node.loc.keyword
        end_loc = node.loc.end

        if kw_loc.line != end_loc.line && kw_loc.column != end_loc.column
          add_offence(:warning,
                      end_loc,
                      sprintf(MSG, end_loc.line, end_loc.column,
                              kw_loc.source, kw_loc.line, kw_loc.column))
        end
      end
    end
  end
end
