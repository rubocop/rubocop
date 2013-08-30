# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for space between a method name and a left parenthesis.
      class SpaceAfterMethodName < Cop
        MSG = 'Never put a space between a method name and the opening ' +
          'parenthesis.'

        def on_def(node)
          _method_name, args, _body = *node
          check(args)
        end

        def on_defs(node)
          _scope, _method_name, args, _body = *node
          check(args)
        end

        def check(args)
          return unless args.loc.begin && args.loc.begin.is?('(')
          expr = args.loc.expression
          pos_before_left_paren = Parser::Source::Range.new(expr.source_buffer,
                                                            expr.begin_pos - 1,
                                                            expr.begin_pos)
          if pos_before_left_paren.source =~ /\s/
            convention(nil, pos_before_left_paren)
          end
        end
      end
    end
  end
end
