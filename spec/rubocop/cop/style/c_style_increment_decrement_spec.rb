# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CStyleIncrementDecrement, :config do
  it 'does not register an offense on an empty string' do
    expect_no_offenses("''")
  end

  it 'registers an offense and autocorrects a variable increment' do
    expect_offense(<<~RUBY)
      ++counter
      ^^^^^^^^^ C-style increment operators are not supported in Ruby. Use `+= 1` instead.
    RUBY

    expect_correction(<<~RUBY)
      counter += 1
    RUBY
  end

  it 'registers an offense and autocorrects a variable decrement' do
    expect_offense(<<~RUBY)
      --counter
      ^^^^^^^^^ C-style decrement operators are not supported in Ruby. Use `-= 1` instead.
    RUBY

    expect_correction(<<~RUBY)
      counter -= 1
    RUBY
  end

  it 'registers an offense and autocorrects an increment assignment' do
    expect_offense(<<~RUBY)
      new_counter = ++counter
                    ^^^^^^^^^ C-style increment operators are not supported in Ruby. Use `+= 1` instead.
    RUBY

    expect_correction(<<~RUBY)
      new_counter = counter += 1
    RUBY
  end

  it 'registers an offense and autocorrects a decrement assignment' do
    expect_offense(<<~RUBY)
      new_counter = --counter
                    ^^^^^^^^^ C-style decrement operators are not supported in Ruby. Use `-= 1` instead.
    RUBY

    expect_correction(<<~RUBY)
      new_counter = counter -= 1
    RUBY
  end

  it 'does not register an offense when adding a positive number' do
    expect_no_offenses('num1 + +negative_number')
  end

  it 'does not register an offense when subtracting a negative number' do
    expect_no_offenses('num1 - -negative_number')
  end
end
