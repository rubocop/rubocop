# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterControlKeyword < Cop
      MSG = 'Use space after control keywords.'
      # elsif and unless are handled by on_if.
      KEYWORDS = %w(if case when while until)

      def on_keyword(node)
        return if node.src.is_a?(Parser::Source::Map::Ternary)

        exp = node.src.expression
        kw = node.src.keyword
        kw_offset = kw.begin_pos - exp.begin_pos
        if exp.to_source[kw_offset..-1].start_with?(kw.to_source + '(')
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
