# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ConcatArrayLiterals, :config do
  it 'registers an offense when using `concat` with single element array literal argument' do
    expect_offense(<<~RUBY)
      arr.concat([item])
          ^^^^^^^^^^^^^^ Use `push(item)` instead of `concat([item])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(item)
    RUBY
  end

  it 'registers an offense when using `concat` with multiple elements array literal argument' do
    expect_offense(<<~RUBY)
      arr.concat([foo, bar])
          ^^^^^^^^^^^^^^^^^^ Use `push(foo, bar)` instead of `concat([foo, bar])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(foo, bar)
    RUBY
  end

  it 'registers an offense when using `concat` with multiline multiple elements array literal argument' do
    expect_offense(<<~RUBY)
      arr.concat([
          ^^^^^^^^ Use `push(foo, bar)` instead of `concat([[...]
        foo,
        bar
      ])
    RUBY

    expect_correction(<<~RUBY)
      arr.push(
        foo,
        bar
      )
    RUBY
  end

  it 'registers an offense when using `concat` with multiple array literal arguments' do
    expect_offense(<<~RUBY)
      arr.concat([foo, bar], [baz])
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `push(foo, bar, baz)` instead of `concat([foo, bar], [baz])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(foo, bar, baz)
    RUBY
  end

  it 'registers an offense when using `concat` with single element `%i` array literal argument' do
    expect_offense(<<~RUBY)
      arr.concat(%i[item])
          ^^^^^^^^^^^^^^^^ Use `push(:item)` instead of `concat(%i[item])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(:item)
    RUBY
  end

  it 'registers an offense when using `concat` with `%I` array literal argument consisting of non basic literals' do
    expect_offense(<<~RUBY)
      arr.concat(%I[item \#{foo}])
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `push` with elements as arguments without array brackets instead of `concat(%I[item \#{foo}])`.
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `concat` with `%W` array literal argument consisting of non basic literals' do
    expect_offense(<<~RUBY)
      arr.concat(%W[item \#{foo}])
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `push` with elements as arguments without array brackets instead of `concat(%W[item \#{foo}])`.
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `concat` with single element `%w` array literal argument' do
    expect_offense(<<~RUBY)
      arr.concat(%w[item])
          ^^^^^^^^^^^^^^^^ Use `push("item")` instead of `concat(%w[item])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push("item")
    RUBY
  end

  it 'does not register an offense when using `concat` with variable argument' do
    expect_no_offenses(<<~RUBY)
      arr.concat(items)
    RUBY
  end

  it 'does not register an offense when using `concat` with array literal and variable arguments' do
    expect_no_offenses(<<~RUBY)
      arr.concat([foo, bar], baz)
    RUBY
  end

  it 'does not register an offense when using `concat` with no arguments' do
    expect_no_offenses(<<~RUBY)
      arr.concat
    RUBY
  end

  it 'does not register an offense when using `push`' do
    expect_no_offenses(<<~RUBY)
      arr.push(item)
    RUBY
  end

  it 'does not register an offense when using `<<`' do
    expect_no_offenses(<<~RUBY)
      arr << item
    RUBY
  end
end
