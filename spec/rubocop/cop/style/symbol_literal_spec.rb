# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SymbolLiteral, :config do
  it 'registers an offense for word-line symbols using string syntax' do
    expect_offense(<<~RUBY)
      x = { :"test" => 0, :"other" => 1 }
                          ^^^^^^^^ Do not use strings for word-like symbol literals.
            ^^^^^^^ Do not use strings for word-like symbol literals.
    RUBY

    expect_correction(<<~RUBY)
      x = { :test => 0, :other => 1 }
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
end
