# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YodaExpression, :config do
  let(:cop_config) { { 'SupportedOperators' => ['*', '+'] } }

  it 'registers an offense when numeric literal on left' do
    expect_offense(<<~RUBY)
      1 + x
      ^^^^^ Non-literal operand (`x`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      x + 1
    RUBY
  end

  it 'registers an offense when constant on left' do
    expect_offense(<<~RUBY)
      CONST + x
      ^^^^^^^^^ Non-literal operand (`x`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      x + CONST
    RUBY
  end

  it 'registers an offense and corrects when using complex use of numeric literals' do
    expect_offense(<<~RUBY)
      2 + (1 + x)
      ^^^^^^^^^^^ Non-literal operand (`(1 + x)`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      (x + 1) + 2
    RUBY
  end

  it 'registers an offense and corrects when using complex use of constants' do
    expect_offense(<<~RUBY)
      TWO + (ONE + x)
      ^^^^^^^^^^^^^^^ Non-literal operand (`(ONE + x)`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      (x + ONE) + TWO
    RUBY
  end

  it 'accepts numeric literal on the right' do
    expect_no_offenses(<<~RUBY)
      x + 42
    RUBY
  end

  it 'accepts constant on the right' do
    expect_no_offenses(<<~RUBY)
      x + FORTY_TWO
    RUBY
  end

  it 'accepts neither numeric literal nor constant' do
    expect_no_offenses(<<~RUBY)
      x + y
    RUBY
  end

  it 'accepts `|`' do
    expect_no_offenses(<<~RUBY)
      1 | x
    RUBY
  end
end
