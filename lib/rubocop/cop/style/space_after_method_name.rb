# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for space between a method name and a left parenthesis in defs.
      #
      # @example
      #
      #   # bad
      #   def func (x) ... end
      #
      #   # good
      #   def func(x) ... end
      class SpaceAfterMethodName < Cop
        include OnMethodDef

        MSG = 'Do not put a space between a method name and the opening ' \
              'parenthesis.'

        def on_method_def(_node, _method_name, args, _body)
          return unless args.loc.begin && args.loc.begin.is?('(')
          expr = args.source_range
          pos_before_left_paren = Parser::Source::Range.new(expr.source_buffer,
                                                            expr.begin_pos - 1,
                                                            expr.begin_pos)
          return unless pos_before_left_paren.source =~ /\s/

          add_offense(pos_before_left_paren, pos_before_left_paren)
        end

        def autocorrect(pos_before_left_paren)
          ->(corrector) { corrector.remove(pos_before_left_paren) }
        end
      end
    end
  end
end
