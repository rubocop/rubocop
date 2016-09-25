# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for word-line symbols using string syntax' do
    inspect_source(cop, 'x = { :"test" => 0 }')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts string syntax when symbols have whitespaces in them' do
    inspect_source(cop, 'x = { :"t o" => 0 }')
    expect(cop.messages).to be_empty
  end

  it 'accepts string syntax when symbols have special chars in them' do
    inspect_source(cop, 'x = { :"\tab" => 1 }')
    expect(cop.messages).to be_empty
  end

  it 'accepts string syntax when symbol start with a digit' do
    inspect_source(cop, 'x = { :"1" => 1 }')
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects by removing quotes' do
    new_source = autocorrect_source(cop, '{ :"ala" => 1, :"bala" => 2 }')
    expect(new_source).to eq('{ :ala => 1, :bala => 2 }')
  end
end
