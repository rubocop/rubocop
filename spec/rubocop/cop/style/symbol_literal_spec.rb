# frozen_string_literal: true

describe RuboCop::Cop::Style::SymbolLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for word-line symbols using string syntax' do
    expect_offense(<<-RUBY.strip_indent)
      x = { :"test" => 0 }
            ^^^^^^^ Do not use strings for word-like symbol literals.
    RUBY
  end

  it 'accepts string syntax when symbols have whitespaces in them' do
    expect_no_offenses('x = { :"t o" => 0 }')
  end

  it 'accepts string syntax when symbols have special chars in them' do
    expect_no_offenses('x = { :"\\tab" => 1 }')
  end

  it 'accepts string syntax when symbol start with a digit' do
    expect_no_offenses('x = { :"1" => 1 }')
  end

  it 'auto-corrects by removing quotes' do
    new_source = autocorrect_source('{ :"ala" => 1, :"bala" => 2 }')
    expect(new_source).to eq('{ :ala => 1, :bala => 2 }')
  end
end
