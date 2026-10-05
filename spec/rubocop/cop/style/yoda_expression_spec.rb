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

  it 'registers an offense and corrects when using suffix form of operator with constant receiver' do
    expect_offense(<<~RUBY)
      1 + CONST.+(ary)
      ^^^^^^^^^^^^^^^^ Non-literal operand (`CONST.+(ary)`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      ary.+(CONST) + 1
    RUBY
  end

  it 'registers an offense and corrects when using suffix form of nullary operator with constant receiver' do
    expect_offense(<<~RUBY)
      1 + CONST.*
      ^^^^^^^^^^^ Non-literal operand (`CONST.*`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      CONST.* + 1
    RUBY
  end

  it 'accepts a splat argument' do
    expect_no_offenses(<<~RUBY)
      CONST.+(*ary)
    RUBY
  end

  it 'accepts a block argument' do
    expect_no_offenses(<<~RUBY)
      CONST.+(&block)
    RUBY
  end

  it 'accepts keyword arguments' do
    expect_no_offenses(<<~RUBY)
      CONST.+(key: value)
      CONST.+(**options)
    RUBY
  end

  it 'accepts argument forwarding', :ruby32 do
    expect_no_offenses(<<~RUBY)
      def do_something(...)
        CONST.+(...)
      end

      def do_something_else(*)
        CONST.+(*)
      end
    RUBY
  end

  it 'registers an offense and corrects when using a hash literal argument' do
    expect_offense(<<~RUBY)
      CONST.+({ key: value })
      ^^^^^^^^^^^^^^^^^^^^^^^ Non-literal operand (`{ key: value }`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      { key: value }.+(CONST)
    RUBY
  end
end
