# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousOperatorPrecedence, :config do
  it 'does not register an offense when there is only one operator in the expression' do
    expect_no_offenses(<<~RUBY)
      a + b
    RUBY
  end

  it 'does not register an offense when all operators in the expression have the same precedence' do
    expect_no_offenses(<<~RUBY)
      a + b + c
      a * b / c % d
      a && b && c
    RUBY
  end

  it 'does not register an offense when expressions are wrapped in parentheses by precedence' do
    expect_no_offenses(<<~RUBY)
      a + (b * c)
      (a ** b) + c
    RUBY
  end

  it 'does not register an offense when expressions are wrapped in parentheses by reverse precedence' do
    expect_no_offenses(<<~RUBY)
      (a + b) * c
      a ** (b + c)
    RUBY
  end

  it 'does not register an offense when boolean expressions are wrapped in parens' do
    expect_no_offenses(<<~RUBY)
      (a && b) || c
      a || (b & c)
    RUBY
  end

  it 'registers an offense when an expression with mixed precedence has no parens' do
    expect_offense(<<~RUBY)
      a + b * c
          ^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
    RUBY

    expect_correction(<<~RUBY)
      a + (b * c)
    RUBY
  end

  it 'registers an offense when an expression with mixed boolean operators has no parens' do
    expect_offense(<<~RUBY)
      a && b || c
      ^^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
      a || b && c
           ^^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
    RUBY

    expect_correction(<<~RUBY)
      (a && b) || c
      a || (b && c)
    RUBY
  end

  it 'registers an offense for expressions containing booleans and operators' do
    expect_offense(<<~RUBY)
      a && b * c
           ^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
      a * b && c
      ^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
    RUBY

    expect_correction(<<~RUBY)
      a && (b * c)
      (a * b) && c
    RUBY
  end

  it 'registers an offense when the entire expression is wrapped in parentheses' do
    expect_offense(<<~RUBY)
      (a + b * c ** d)
               ^^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
           ^^^^^^^^^^ Wrap expressions with varying precedence with parentheses to avoid ambiguity.
    RUBY

    expect_correction(<<~RUBY)
      (a + (b * (c ** d)))
    RUBY
  end

  it 'corrects a super long expression in precedence order' do
    expect_offense(<<~RUBY)
      a ** b * c / d % e + f - g << h >> i & j | k ^ l && m || n
      ^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
    RUBY

    expect_correction(<<~RUBY)
      (((((((a ** b) * c / d % e) + f - g) << h >> i) & j) | k ^ l) && m) || n
    RUBY
  end

  it 'corrects a super long expression in reverse precedence order' do
    expect_offense(<<~RUBY)
      a || b && c | d ^ e & f << g >> h + i - j * k / l % n ** m
                                                          ^^^^^^ Wrap expressions [...]
                                              ^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wrap expressions [...]
    RUBY

    expect_correction(<<~RUBY)
      a || (b && (c | d ^ (e & (f << g >> (h + i - (j * k / l % (n ** m)))))))
    RUBY
  end

  it 'allows an operator with `and`' do
    expect_no_offenses(<<~RUBY)
      array << i and next
    RUBY
  end

  it 'allows an operator with `or`' do
    expect_no_offenses(<<~RUBY)
      array << i or return
    RUBY
  end
end
