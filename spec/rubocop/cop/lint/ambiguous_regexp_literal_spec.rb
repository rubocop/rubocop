# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::AmbiguousRegexpLiteral do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'with a regexp literal in the first argument' do
    context 'without parentheses' do
      let(:source) { 'p /pattern/' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(
          'Ambiguous regexp literal. Parenthesize the method arguments ' \
          "if it's surely a regexp literal, or add a whitespace to the " \
          'right of the `/` if it should be a division.'
        )
        expect(cop.highlights).to eq(['/'])
      end
    end

    context 'with parentheses' do
      let(:source) { 'p(/pattern/)' }

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end
  end
end
