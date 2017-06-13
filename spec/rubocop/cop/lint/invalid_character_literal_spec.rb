# frozen_string_literal: true

describe RuboCop::Cop::Lint::InvalidCharacterLiteral do
  subject(:cop) { described_class.new }

  # Is there a way to emit this warning without syntax error?
  #
  #   $ ruby -w
  #   p(? )
  #   -:1: warning: invalid character syntax; use ?\s
  #   -:1: syntax error, unexpected '?', expecting ')'
  #   p(? )
  #      ^
  #
  # https://github.com/ruby/ruby/blob/v2_1_0/parse.y#L7276
  # https://github.com/whitequark/parser/blob/v2.1.2/lib/parser/lexer.rl#L1660
  context 'with a non-escaped whitespace character literal' do
    let(:source) { 'p(? )' }

    it 'registers an offense' do
      pending 'Is there a way to emit this warning without syntax errors?'

      inspect_source(source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Invalid character literal; use ?\s')
      expect(cop.highlights).to eq([' '])
    end
  end
end
