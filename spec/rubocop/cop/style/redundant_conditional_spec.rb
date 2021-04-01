# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantConditional, :config do
  it 'registers an offense for ternary with boolean results' do
    expect_offense(<<~RUBY)
      x == y ? true : false
      ^^^^^^^^^^^^^^^^^^^^^ This conditional expression can just be replaced by `x == y`.
    RUBY

    expect_correction(<<~RUBY)
      x == y
    RUBY
  end

  it 'registers an offense for ternary with negated boolean results' do
    expect_offense(<<~RUBY)
      x == y ? false : true
      ^^^^^^^^^^^^^^^^^^^^^ This conditional expression can just be replaced by `!(x == y)`.
    RUBY

    expect_correction(<<~RUBY)
      !(x == y)
    RUBY
  end

  it 'allows ternary with non-boolean results' do
    expect_no_offenses('x == y ? 1 : 10')
  end

  it 'registers an offense for if/else with boolean results' do
    expect_offense(<<~RUBY)
      if x == y
      ^^^^^^^^^ This conditional expression can just be replaced by `x == y`.
        true
      else
        false
      end
    RUBY

    expect_correction(<<~RUBY)
      x == y
    RUBY
  end

  it 'registers an offense for if/else with negated boolean results' do
    expect_offense(<<~RUBY)
      if x == y
      ^^^^^^^^^ This conditional expression can just be replaced by `!(x == y)`.
        false
      else
        true
      end
    RUBY

    expect_correction(<<~RUBY)
      !(x == y)
    RUBY
  end

  it 'registers an offense for if/elsif/else with boolean results' do
    expect_offense(<<~RUBY)
      if cond
        false
      elsif x == y
      ^^^^^^^^^^^^ This conditional expression can just be replaced by [...]
        true
      else
        false
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
        false
      else
        x == y
      end
    RUBY
  end

  it 'registers an offense for if/elsif/else with negated boolean results' do
    expect_offense(<<~RUBY)
      if cond
        false
      elsif x == y
      ^^^^^^^^^^^^ This conditional expression can just be replaced by [...]
        false
      else
        true
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
        false
      else
        !(x == y)
      end
    RUBY
  end

  it 'does not register an offense for if/else with non-boolean results' do
    expect_no_offenses(<<~RUBY)
      if x == y
        1
      else
        2
      end
    RUBY
  end

  it 'does not register an offense for if/elsif/else with non-boolean results' do
    expect_no_offenses(<<~RUBY)
      if cond
        1
      elsif x == y
        2
      else
        3
      end
    RUBY
  end
end
