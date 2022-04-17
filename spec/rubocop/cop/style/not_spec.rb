# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Not, :config do
  it 'registers an offense for not' do
    expect_offense(<<~RUBY)
      not test
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !test
    RUBY
  end

  it 'does not register an offense for !' do
    expect_no_offenses('!test')
  end

  it 'autocorrects "not" with !' do
    expect_offense(<<~RUBY)
      x = 10 if not y
                ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      x = 10 if !y
    RUBY
  end

  it 'autocorrects "not" followed by parens with !' do
    expect_offense(<<~RUBY)
      not(test)
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !(test)
    RUBY
  end

  it 'uses the reverse operator when `not` is applied to a comparison' do
    expect_offense(<<~RUBY)
      not x < y
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      x >= y
    RUBY
  end

  it 'parenthesizes when `not` would change the meaning of a binary exp' do
    expect_offense(<<~RUBY)
      not a >> b
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !(a >> b)
    RUBY
  end

  it 'parenthesizes when `not` is applied to a ternary op' do
    expect_offense(<<~RUBY)
      not a ? b : c
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !(a ? b : c)
    RUBY
  end

  it 'parenthesizes when `not` is applied to and' do
    expect_offense(<<~RUBY)
      not a && b
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !(a && b)
    RUBY
  end

  it 'parenthesizes when `not` is applied to or' do
    expect_offense(<<~RUBY)
      not a || b
      ^^^ Use `!` instead of `not`.
    RUBY

    expect_correction(<<~RUBY)
      !(a || b)
    RUBY
  end
end
