# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumericOperationWithConstantResult, :config do
  it 'registers an offense when a variable is subtracted from itself' do
    expect_offense(<<~RUBY)
      x - x
      ^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when a variable is multiplied by 0' do
    expect_offense(<<~RUBY)
      x * 0
      ^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when the modulo of variable and 1 is taken' do
    expect_offense(<<~RUBY)
      x % 1
      ^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when the modulo of variable and itself is taken' do
    expect_offense(<<~RUBY)
      x % x
      ^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when a variable is divided by itself' do
    expect_offense(<<~RUBY)
      x / x
      ^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end

  it 'registers an offense when a variable is raised to the power of 0' do
    expect_offense(<<~RUBY)
      x ** 0
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end

  it 'registers an offense when a variable is subtracted from itself via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x -= x
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 0
    RUBY
  end

  it 'registers an offense when a variable is multiplied by 0 via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x *= 0
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 0
    RUBY
  end

  it 'registers an offense when the modulo of variable and 1 is taken via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x %= 1
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 0
    RUBY
  end

  it 'registers an offense when the modulo of variable and itself is taken via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x %= x
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 0
    RUBY
  end

  it 'registers an offense when a variable is divided by itself via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x /= x
      ^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 1
    RUBY
  end

  it 'egisters an offense when a variable is raised to the power of 0 via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x **= 0
      ^^^^^^^ Do not apply numeric operations with constant results to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = 1
    RUBY
  end
end
