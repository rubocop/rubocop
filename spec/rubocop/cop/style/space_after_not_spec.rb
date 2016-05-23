# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterNot do
  subject(:cop) { described_class.new }

  it 'reports an offense for space after !' do
    inspect_source(cop, '! something')

    expect(cop.messages)
      .to eq(['Do not leave space between `!` and its argument.'])
    expect(cop.highlights).to eq(['! something'])
  end

  it 'accepts no space after !' do
    inspect_source(cop, '!something')

    expect(cop.offenses).to be_empty
  end

  it 'accepts space after not keyword' do
    inspect_source(cop, 'not something')

    expect(cop.offenses).to be_empty
  end

  it 'reports an offense for space after ! with the negated receiver ' \
     'wrapped in parentheses' do
    inspect_source(cop, '! (model)')

    expect(cop.messages)
      .to eq(['Do not leave space between `!` and its argument.'])
    expect(cop.highlights).to eq(['! (model)'])
  end

  context 'auto-correct' do
    it 'removes redundant space' do
      new_source = autocorrect_source(cop, '!  something')

      expect(new_source).to eq('!something')
    end

    it 'keeps space after not keyword' do
      new_source = autocorrect_source(cop, 'not something')

      expect(new_source).to eq('not something')
    end

    it 'removes redundant space when there is a parentheses' do
      new_source = autocorrect_source(cop, '!  (model)')

      expect(new_source).to eq('!(model)')
    end
  end
end
