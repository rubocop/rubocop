# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for space between a method name and a left parenthesis.
      class SpaceAfterMethodName < Cop
        include CheckMethods

        MSG = 'Never put a space between a method name and the opening ' \
          'parenthesis.'

        def check(_node, _method_name, args, body)
          return unless args.loc.begin && args.loc.begin.is?('(')
          expr = args.loc.expression
          pos_before_left_paren = Parser::Source::Range.new(expr.source_buffer,
                                                            expr.begin_pos - 1,
                                                            expr.begin_pos)
          if pos_before_left_paren.source =~ /\s/
            add_offence(pos_before_left_paren, pos_before_left_paren)
          end
        end

        def autocorrect(pos_before_left_paren)
          @corrections << lambda do |corrector|
            corrector.remove(pos_before_left_paren)
          end
        end
      end
    end
  end
end
