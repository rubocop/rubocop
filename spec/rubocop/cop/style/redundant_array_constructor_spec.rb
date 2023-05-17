# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantArrayConstructor, :config do
  it 'registers an offense when using an empty array literal argument for `Array.new`' do
    expect_offense(<<~RUBY)
      Array.new([])
      ^^^^^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      []
    RUBY
  end

  it 'registers an offense when using an empty array literal argument for `::Array.new`' do
    expect_offense(<<~RUBY)
      ::Array.new([])
      ^^^^^^^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      []
    RUBY
  end

  it 'registers an offense when using an empty array literal argument for `Array[]`' do
    expect_offense(<<~RUBY)
      Array[]
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      []
    RUBY
  end

  it 'registers an offense when using an empty array literal argument for `::Array[]`' do
    expect_offense(<<~RUBY)
      ::Array[]
      ^^^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      []
    RUBY
  end

  it 'registers an offense when using an empty array literal argument for `Array([])`' do
    expect_offense(<<~RUBY)
      Array([])
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      []
    RUBY
  end

  it 'registers an offense when using an array literal with some elements as an argument for `Array.new`' do
    expect_offense(<<~RUBY)
      Array.new(['foo', 'bar', 'baz'])
      ^^^^^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      ['foo', 'bar', 'baz']
    RUBY
  end

  it 'registers an offense when using an array literal with some elements as an argument for `Array[]`' do
    expect_offense(<<~RUBY)
      Array['foo', 'bar', 'baz']
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      ['foo', 'bar', 'baz']
    RUBY
  end

  it 'registers an offense when using an array literal with some elements as an argument for `Array([])`' do
    expect_offense(<<~RUBY)
      Array(['foo', 'bar', 'baz'])
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      ['foo', 'bar', 'baz']
    RUBY
  end

  it 'does not register an offense when using an array literal' do
    expect_no_offenses(<<~RUBY)
      []
    RUBY
  end

  it 'does not register an offense when using single argument for `Array.new`' do
    expect_no_offenses(<<~RUBY)
      Array.new(array)
    RUBY
  end

  it 'does not register an offense when using single argument for `Array()`' do
    expect_no_offenses(<<~RUBY)
      Array(array)
    RUBY
  end

  it 'does not register an offense when using two argument for `Array.new`' do
    expect_no_offenses(<<~RUBY)
      Array.new(3, 'foo')
    RUBY
  end

  it 'does not register an offense when using block argument for `Array.new`' do
    expect_no_offenses(<<~RUBY)
      Array.new(3) { 'foo' }
    RUBY
  end
end
