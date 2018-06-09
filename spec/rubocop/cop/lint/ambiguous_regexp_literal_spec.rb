# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousRegexpLiteral do
  subject(:cop) { described_class.new }

  context 'with a regexp literal in the first argument' do
    context 'without parentheses' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          p /pattern/
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY
      end
    end

    context 'with parentheses' do
      it 'accepts' do
        expect_no_offenses('p(/pattern/)')
      end
    end
  end
end
