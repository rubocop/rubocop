# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumericOperationWithConstantResult, :config do
  it 'registers an offense when a variable is multiplied by 0' do
    expect_offense(<<~RUBY)
      x * 0
      ^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when a variable is divided by itself' do
    expect_offense(<<~RUBY)
      x / x
      ^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end

  it 'registers an offense when a variable is raised to the power of 0' do
    expect_offense(<<~RUBY)
      x ** 0
      ^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end

  it 'registers an offense when a variable is multiplied by 0 via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x *= 0
      ^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      x = 0
    RUBY
  end

  it 'registers an offense when a variable is divided by itself via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x /= x
      ^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      x = 1
    RUBY
  end

  it 'registers an offense when a variable is raised to the power of 0 via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x **= 0
      ^^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      x = 1
    RUBY
  end

  [
    'x - x',
    'x -= x',
    'x % x',
    'x %= x',
    'x % 1',
    'x %= 1'
  ].each do |expression|
    it "registers no offense for `#{expression}`" do
      expect_no_offenses(expression)
    end
  end

  it 'registers an offense when a variable is multiplied by 0 using dot notation' do
    expect_offense(<<~RUBY)
      x.*(0)
      ^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when a variable is divided by using dot notation' do
    expect_offense(<<~RUBY)
      x./(x)
      ^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end

  it 'registers an offense when a variable is multiplied by 0 using safe navigation' do
    expect_offense(<<~RUBY)
      x&.*(0)
      ^^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      0
    RUBY
  end

  it 'registers an offense when a variable is divided by using safe navigation' do
    expect_offense(<<~RUBY)
      x&./(x)
      ^^^^^^^ Numeric operation with a constant result detected.
    RUBY

    expect_correction(<<~RUBY)
      1
    RUBY
  end
end
