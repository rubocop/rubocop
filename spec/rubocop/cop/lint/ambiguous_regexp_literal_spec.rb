# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::AmbiguousRegexpLiteral do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'with a regexp literal in the first argument' do
    context 'without parentheses' do
      let(:source) { 'p /pattern/' }

      it 'registers an offence' do
        expect(cop.offences.size).to eq(1)
        expect(cop.offences.first.message).to eq(
          'Ambiguous regexp literal. Parenthesize the method arguments ' \
          "if it's surely a regexp literal, or add a whitespace to the " +
          'right of the / if it should be a division.'
        )
        expect(cop.highlights).to eq(['/'])
      end
    end

    context 'with parentheses' do
      let(:source) { 'p(/pattern/)' }

      it 'accepts' do
        expect(cop.offences).to be_empty
      end
    end
  end
end
