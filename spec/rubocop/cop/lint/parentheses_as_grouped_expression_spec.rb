# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ParenthesesAsGroupedExpression, :config do
  it 'registers an offense and corrects for method call with space before the parenthesis' do
    expect_offense(<<~RUBY)
      a.func (x)
            ^ `(x)` interpreted as grouped expression.
    RUBY

    expect_correction(<<~RUBY)
      a.func(x)
    RUBY
  end

  it 'registers an offense and corrects for predicate method call with space ' \
     'before the parenthesis' do
    expect_offense(<<~RUBY)
      is? (x)
         ^ `(x)` interpreted as grouped expression.
    RUBY

    expect_correction(<<~RUBY)
      is?(x)
    RUBY
  end

  it 'registers an offense and corrects for method call with space before the parenthesis when block argument and parenthesis' do
    expect_offense(<<~RUBY)
      a.concat ((1..1).map { |i| i * 10 })
              ^ `((1..1).map { |i| i * 10 })` interpreted as grouped expression.
    RUBY

    expect_correction(<<~RUBY)
      a.concat((1..1).map { |i| i * 10 })
    RUBY
  end

  it 'does not register an offense method call with space before the parenthesis when block argument is no parenthesis' do
    expect_no_offenses(<<~RUBY)
      a.concat (1..1).map { |i| i * 10 }
    RUBY
  end

  context 'when using numbered parameter', :ruby27 do
    it 'registers an offense and corrects for method call with space before the parenthesis when block argument and parenthesis' do
      expect_offense(<<~RUBY)
        a.concat ((1..1).map { _1 * 10 })
                ^ `((1..1).map { _1 * 10 })` interpreted as grouped expression.
      RUBY

      expect_correction(<<~RUBY)
        a.concat((1..1).map { _1 * 10 })
      RUBY
    end

    it 'does not register an offense for method call with space before the parenthesis when block argument is no parenthesis' do
      expect_no_offenses(<<~RUBY)
        a.concat (1..1).map { _1 * 10 }
      RUBY
    end
  end

  it 'does not register an offense for expression followed by an operator' do
    expect_no_offenses(<<~RUBY)
      func (x) || y
    RUBY
  end

  it 'does not register an offense for expression followed by chained expression' do
    expect_no_offenses(<<~RUBY)
      func (x).func.func.func.func.func
    RUBY
  end

  it 'does not register an offense for expression followed by chained expression with safe navigation operator' do
    expect_no_offenses(<<~RUBY)
      func (x).func.func.func.func&.func
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

  it 'does not register an offense when method argument parentheses are omitted and ' \
     'hash argument key is enclosed in parentheses' do
    expect_no_offenses(<<~RUBY)
      transition (foo - bar) => value
    RUBY
  end

  it 'does not register an offense for ternary operator' do
    expect_no_offenses(<<~RUBY)
      foo (cond) ? 1 : 2
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

  it 'does not register an offense when heredoc has a space between the same string as the method name and `(`' do
    expect_no_offenses(<<~RUBY)
      foo(
        <<~EOS
          foo (
          )
        EOS
      )
    RUBY
  end

  context 'when using safe navigation operator' do
    it 'registers an offense and corrects for method call with space before the parenthesis' do
      expect_offense(<<~RUBY)
        a&.func (x)
               ^ `(x)` interpreted as grouped expression.
      RUBY

      expect_correction(<<~RUBY)
        a&.func(x)
      RUBY
    end
  end
end
