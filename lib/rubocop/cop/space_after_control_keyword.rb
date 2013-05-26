# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterControlKeyword < Cop
      MSG = 'Use space after control keywords.'
      # elsif and unless are handled by on_if.
      KEYWORDS = %w(if case when while until)

      def on_keyword(node)
        return if node.loc.is_a?(Parser::Source::Map::Ternary)

        exp = node.loc.expression
        kw = node.loc.keyword
        kw_offset = kw.begin_pos - exp.begin_pos
        if exp.source[kw_offset..-1].start_with?(kw.source + '(')
          add_offence(:convention, kw.line, MSG)
        end
      end

      KEYWORDS.each do |keyword|
        define_method(:"on_#{keyword}") do |node|
          on_keyword(node)
          super(node)
        end
      end
    end
  end
end
