# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ParenthesesAsGroupedExpression do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects for method call with space before ' \
     'the parenthesis' do
    expect_offense(<<~RUBY)
      a.func (x)
            ^ `(...)` interpreted as grouped expression.
    RUBY

    expect_correction(<<~RUBY)
      a.func(x)
    RUBY
  end

  it 'registers an offense and corrects for predicate method call with space ' \
     'before the parenthesis' do
    expect_offense(<<~RUBY)
      is? (x)
         ^ `(...)` interpreted as grouped expression.
    RUBY

    expect_correction(<<~RUBY)
      is?(x)
    RUBY
  end

  it 'does not register an offense for math expression' do
    expect_no_offenses(<<~RUBY)
      puts (2 + 3) * 4
    RUBY
  end

  it 'does not register an offense for math expression with `to_i`' do
    expect_no_offenses(<<~RUBY)
      do_something.eq (foo * bar).to_i
    RUBY
  end

  it 'accepts a method call without arguments' do
    expect_no_offenses('func')
  end

  it 'accepts a method call with arguments but no parentheses' do
    expect_no_offenses('puts x')
  end

  it 'accepts a chain of method calls' do
    expect_no_offenses(<<~RUBY)
      a.b
      a.b 1
      a.b(1)
    RUBY
  end

  it 'accepts method with parens as arg to method without' do
    expect_no_offenses('a b(c)')
  end

  it 'accepts an operator call with argument in parentheses' do
    expect_no_offenses(<<~RUBY)
      a % (b + c)
      a.b = (c == d)
    RUBY
  end

  it 'accepts a space inside opening paren followed by left paren' do
    expect_no_offenses('a( (b) )')
  end

  it 'does not register an offense for a call with multiple arguments' do
    expect_no_offenses('assert_equal (0..1.9), acceleration.domain')
  end

  context 'when using safe navigation operator' do
    it 'registers an offense and corrects for method call with space before ' \
       'the parenthesis' do
      expect_offense(<<~RUBY)
        a&.func (x)
               ^ `(...)` interpreted as grouped expression.
      RUBY

      expect_correction(<<~RUBY)
        a&.func(x)
      RUBY
    end
  end
end
