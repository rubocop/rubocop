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

  it 'registers an offense when using safe navigation `concat` with single element array literal argument' do
    expect_offense(<<~RUBY)
      arr&.concat([item])
           ^^^^^^^^^^^^^^ Use `push(item)` instead of `concat([item])`.
    RUBY

    expect_correction(<<~RUBY)
      arr&.push(item)
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

  it 'registers an offense when using `concat` with multiple multiline array literal arguments' do
    expect_offense(<<~RUBY)
      arr.concat([
          ^^^^^^^^ Use `push(foo, bar)` instead of `concat([[...]
        foo
      ], [
        bar
      ])
    RUBY

    expect_correction(<<~RUBY)
      arr.push(
        foo,#{trailing_whitespace}
        bar
      )
    RUBY
  end

  it 'registers an offense when using `concat` with multiple multiline array literal arguments with trailing commas' do
    expect_offense(<<~RUBY)
      arr.concat([
          ^^^^^^^^ Use `push(foo, bar)` instead of `concat([[...]
        foo,
      ], [
        bar,
      ])
    RUBY

    expect_correction(<<~RUBY)
      arr.push(
        foo,#{trailing_whitespace}
        bar,
      )
    RUBY
  end

  it 'registers an offense when using `concat` with a trailing comma in an array literal argument that is not the last' do
    expect_offense(<<~RUBY)
      arr.concat([foo,], [bar])
          ^^^^^^^^^^^^^^^^^^^^^ Use `push(foo, bar)` instead of `concat([foo,], [bar])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(foo, bar)
    RUBY
  end

  it 'registers an offense but does not autocorrect when a comment precedes the closing bracket of an array literal argument that is not the last' do
    expect_offense(<<~RUBY)
      arr.concat([
          ^^^^^^^^ Use `push(foo, bar)` instead of `concat([[...]
        foo # comment
      ], [
        bar
      ])
    RUBY

    expect_no_corrections
  end

  it 'registers an offense but does not autocorrect when a heredoc ends an array literal argument that is not the last' do
    expect_offense(<<~RUBY)
      arr.concat([
          ^^^^^^^^ Use `push(<<~TEXT, bar)` instead of `concat([[...]
        <<~TEXT
          foo
        TEXT
      ], [
        bar
      ])
    RUBY

    expect_no_corrections
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

  it 'registers an offense but does not autocorrect when using `concat` with `%W` containing interpolation' do
    expect_offense(<<~'RUBY')
      arr.concat(%W[#{foo}])
          ^^^^^^^^^^^^^^^^^^ Use `push` with elements as arguments without array brackets instead of `concat(%W[#{foo}])`.
    RUBY

    expect_no_corrections
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

  it 'registers an offense and corrects when an argument is an empty array literal' do
    expect_offense(<<~RUBY)
      arr.concat([], [b])
          ^^^^^^^^^^^^^^^ Use `push(b)` instead of `concat([], [b])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(b)
    RUBY
  end

  it 'registers an offense and corrects with an empty array literal between non-empty ones' do
    expect_offense(<<~RUBY)
      arr.concat([a], [], [b])
          ^^^^^^^^^^^^^^^^^^^^ Use `push(a, b)` instead of `concat([a], [], [b])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(a, b)
    RUBY
  end

  it 'registers an offense but does not autocorrect when an argument is an empty array literal and the call contains comments' do
    expect_offense(<<~RUBY)
      arr.concat([ # keep me
          ^^^^^^^^^^^^^^^^^^ Use `push('b')` instead of `concat([ # keep me[...]
      ], [
        'b' # and me
      ])
    RUBY

    expect_no_corrections
  end

  it 'registers an offense and corrects when an argument is an empty array literal and a comment follows the call' do
    expect_offense(<<~RUBY)
      arr.concat([], [b]) # comment
          ^^^^^^^^^^^^^^^ Use `push(b)` instead of `concat([], [b])`.
    RUBY

    expect_correction(<<~RUBY)
      arr.push(b) # comment
    RUBY
  end

  it 'registers an offense but does not autocorrect when using `concat` with `%w` array literal argument and the call contains a comment' do
    expect_offense(<<~RUBY)
      arr.concat(%w[a], [
          ^^^^^^^^^^^^^^^ Use `push("a", b)` instead of `concat(%w[a], [[...]
        b # comment
      ])
    RUBY

    expect_no_corrections
  end
end
