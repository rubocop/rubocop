# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceBeforeComma do
  subject(:cop) { described_class.new }

  it 'registers an offense for block argument with space before comma' do
    inspect_source(cop, 'each { |s , t| }')
    expect(cop.messages).to eq(
      ['Space found before comma.']
    )
  end

  it 'registers an offense for array index with space before comma' do
    inspect_source(cop, 'formats[0 , 1]')
    expect(cop.messages).to eq(
      ['Space found before comma.']
    )
  end

  it 'registers an offense for method call arg with space before comma' do
    inspect_source(cop, 'a(1 , 2)')
    expect(cop.messages).to eq(
      ['Space found before comma.']
    )
  end

  it 'does not register an offense for no spaces before comma' do
    inspect_source(cop, 'a(1, 2)')
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects space before comma' do
    new_source = autocorrect_source(cop,
                                    'each { |s , t| a(1 , formats[0 , 1])}')
    expect(new_source).to eq('each { |s, t| a(1, formats[0, 1])}')
  end

  it 'handles more than one space before a comma' do
    new_source = autocorrect_source(cop,
                                    'each { |s  , t| a(1  , formats[0  , 1])}')
    expect(new_source).to eq('each { |s, t| a(1, formats[0, 1])}')
  end
end
