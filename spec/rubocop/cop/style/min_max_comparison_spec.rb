# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MinMaxComparison, :config do
  it 'registers and corrects an offense when using `a > b ? a : b`' do
    expect_offense(<<~RUBY)
      a > b ? a : b
      ^^^^^^^^^^^^^ Use `[a, b].max` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'registers and corrects an offense when using `a >= b ? a : b`' do
    expect_offense(<<~RUBY)
      a >= b ? a : b
      ^^^^^^^^^^^^^^ Use `[a, b].max` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'registers and corrects an offense when using `a < b ? b : a`' do
    expect_offense(<<~RUBY)
      a < b ? b : a
      ^^^^^^^^^^^^^ Use `[a, b].max` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'registers and corrects an offense when using `a <= b ? b : a`' do
    expect_offense(<<~RUBY)
      a <= b ? b : a
      ^^^^^^^^^^^^^^ Use `[a, b].max` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'registers and corrects an offense when using `a < b ? a : b`' do
    expect_offense(<<~RUBY)
      a < b ? a : b
      ^^^^^^^^^^^^^ Use `[a, b].min` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].min
    RUBY
  end

  it 'registers and corrects an offense when using `a <= b ? a : b`' do
    expect_offense(<<~RUBY)
      a <= b ? a : b
      ^^^^^^^^^^^^^^ Use `[a, b].min` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].min
    RUBY
  end

  it 'registers and corrects an offense when using `a > b ? b : a`' do
    expect_offense(<<~RUBY)
      a > b ? b : a
      ^^^^^^^^^^^^^ Use `[a, b].min` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].min
    RUBY
  end

  it 'registers and corrects an offense when using `a >= b ? b : a`' do
    expect_offense(<<~RUBY)
      a >= b ? b : a
      ^^^^^^^^^^^^^^ Use `[a, b].min` instead.
    RUBY

    expect_correction(<<~RUBY)
      [a, b].min
    RUBY
  end

  it 'registers and corrects an offense when using `a > b a : b` with `if/else`' do
    expect_offense(<<~RUBY)
      if a > b
      ^^^^^^^^ Use `[a, b].max` instead.
        a
      else
        b
      end
    RUBY

    expect_correction(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'registers and corrects an offense when using `a < b a : b` with `if/else`' do
    expect_offense(<<~RUBY)
      if a < b
      ^^^^^^^^ Use `[a, b].min` instead.
        a
      else
        b
      end
    RUBY

    expect_correction(<<~RUBY)
      [a, b].min
    RUBY
  end

  it 'registers and corrects an offense when using `a < b a : b` with `elsif/else`' do
    expect_offense(<<~RUBY)
      if x
      elsif a < b
      ^^^^^^^^^^^ Use `[a, b].min` instead.
        a
      else
        b
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
      else
        [a, b].min
      end
    RUBY
  end

  it 'does not register an offense when using `a > b ? c : d`' do
    expect_no_offenses(<<~RUBY)
      a > b ? c : d
    RUBY
  end

  it 'does not register an offense when using `condition ? a : b`' do
    expect_no_offenses(<<~RUBY)
      condition ? a : b
    RUBY
  end

  it 'does not register an offense when using `elsif`' do
    expect_no_offenses(<<~RUBY)
      if a
      elsif foo(b)
        b
      end
    RUBY
  end

  it 'does not register an offense when using `[a, b].max`' do
    expect_no_offenses(<<~RUBY)
      [a, b].max
    RUBY
  end

  it 'does not register an offense when using `[a, b].min`' do
    expect_no_offenses(<<~RUBY)
      [a, b].min
    RUBY
  end
end
