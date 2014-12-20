# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceBeforeSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense for space before semicolon' do
    inspect_source(cop, 'x = 1 ; y = 2')
    expect(cop.messages).to eq(
      ['Space found before semicolon.'])
  end

  it 'does not register an offense for no space before semicolons' do
    inspect_source(cop, 'x = 1; y = 2')
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects space before semicolon' do
    new_source = autocorrect_source(cop, 'x = 1 ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  it 'handles more than one space before a semicolon' do
    new_source = autocorrect_source(cop, 'x = 1  ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end
end
