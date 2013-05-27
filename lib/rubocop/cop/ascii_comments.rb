# encoding: utf-8

module Rubocop
  module Cop
    class AsciiComments < Cop
      MSG = 'Use only ascii symbols in comments.'

      def on_comment(c)
        add_offence(:convention, c.pos.line, MSG) if c.text =~ /[^\x00-\x7f]/
      end
    end
  end
end
