# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessNumericOperation, :config do
  it 'registers an offense when 0 is added to a variable' do
    expect_offense(<<~RUBY)
      x + 0
      ^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x
    RUBY
  end

  it 'registers an offense when 0 is subtracted from a variable' do
    expect_offense(<<~RUBY)
      x - 0
      ^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x
    RUBY
  end

  it 'registers an offense when a variable is multiplied by 1' do
    expect_offense(<<~RUBY)
      x * 1
      ^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x
    RUBY
  end

  it 'registers an offense when a variable is divided by 1' do
    expect_offense(<<~RUBY)
      x / 1
      ^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x
    RUBY
  end

  it 'registers an offense when a variable is raised to the power of 1' do
    expect_offense(<<~RUBY)
      x ** 1
      ^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x
    RUBY
  end

  it 'registers an offense when a variable is set to itself plus zero via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x += 0
      ^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = x
    RUBY
  end

  it 'registers an offense when a variable is set to itself minus zero via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x -= 0
      ^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = x
    RUBY
  end

  it 'registers an offense when a variable is set to itself times one via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x *= 1
      ^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = x
    RUBY
  end

  it 'registers an offense when a variable is set to itself divided by one via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x /= 1
      ^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = x
    RUBY
  end

  it 'registers an offense when a variable is set to itself raised to the power of one via abbreviated assignment' do
    expect_offense(<<~RUBY)
      x **= 1
      ^^^^^^^ Do not apply inconsequential numeric operations to variables.
    RUBY

    expect_correction(<<~RUBY)
      x = x
    RUBY
  end
end
