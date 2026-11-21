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

  it 'registers an offense when `Array[]` is nested in `Array[]`' do
    expect_offense(<<~RUBY)
      Array[Array[Integer]]
            ^^^^^ Remove the redundant `Array` constructor.
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      [[Integer]]
    RUBY
  end

  it 'registers an offense when `Array.new` is nested in `Array.new`' do
    expect_offense(<<~RUBY)
      Array.new([Array.new([1])])
                 ^^^^^^^^^ Remove the redundant `Array` constructor.
      ^^^^^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      [[1]]
    RUBY
  end

  it 'registers an offense when `Array([])` is nested in `Array([])`' do
    expect_offense(<<~RUBY)
      Array([Array([1])])
             ^^^^^ Remove the redundant `Array` constructor.
      ^^^^^ Remove the redundant `Array` constructor.
    RUBY

    expect_correction(<<~RUBY)
      [[1]]
    RUBY
  end

  it 'does not autocorrect when the heredoc ends between the array and the closing parenthesis' do
    expect_offense(<<~RUBY)
      register(Array.new([<<~MSG]
               ^^^^^^^^^ Remove the redundant `Array` constructor.
        keep this text
      MSG
      ))
    RUBY

    expect_no_corrections
  end

  it 'does not autocorrect when there is a comment outside the array literal' do
    expect_offense(<<~RUBY)
      Array(
      ^^^^^ Remove the redundant `Array` constructor.
        [name] # keep
      )
    RUBY

    expect_no_corrections
  end

  it 'keeps a heredoc and a comment inside the array literal' do
    expect_offense(<<~RUBY)
      Array.new([
      ^^^^^^^^^ Remove the redundant `Array` constructor.
        <<~MSG, # keep
          text
        MSG
      ])
    RUBY

    expect_correction(<<~RUBY)
      [
        <<~MSG, # keep
          text
        MSG
      ]
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
