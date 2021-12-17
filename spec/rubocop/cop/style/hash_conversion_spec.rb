# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashConversion, :config do
  it 'reports an offense for single-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[ary]
      ^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      ary.to_h
    RUBY
  end

  it 'reports different offense for multi-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a, b, c, d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_correction(<<~RUBY)
      {a => b, c => d}
    RUBY
  end

  it 'reports different offense for hash argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a: b, c: d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[key: value, ...].
    RUBY

    expect_correction(<<~RUBY)
      {a: b, c: d}
    RUBY
  end

  it 'reports different offense for hash argument Hash[] as a method argument with parentheses' do
    expect_offense(<<~RUBY)
      do_something(Hash[a: b, c: d], 42)
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[key: value, ...].
    RUBY

    expect_correction(<<~RUBY)
      do_something({a: b, c: d}, 42)
    RUBY
  end

  it 'reports different offense for hash argument Hash[] as a method argument without parentheses' do
    expect_offense(<<~RUBY)
      do_something Hash[a: b, c: d], 42
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[key: value, ...].
    RUBY

    expect_correction(<<~RUBY)
      do_something({a: b, c: d}, 42)
    RUBY
  end

  it 'reports different offense for empty Hash[]' do
    expect_offense(<<~RUBY)
      Hash[]
      ^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_correction(<<~RUBY)
      {}
    RUBY
  end

  it 'registers and corrects an offense when using multi-argument `Hash[]` as a method argument' do
    expect_offense(<<~RUBY)
      do_something Hash[a, b, c, d], arg
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_correction(<<~RUBY)
      do_something({a => b, c => d}, arg)
    RUBY
  end

  it 'does not try to correct multi-argument Hash with odd number of arguments' do
    expect_offense(<<~RUBY)
      Hash[a, b, c]
      ^^^^^^^^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_no_corrections
  end

  it 'wraps complex statements in parens if needed' do
    expect_offense(<<~RUBY)
      Hash[a.foo :bar]
      ^^^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      (a.foo :bar).to_h
    RUBY
  end

  it 'registers and corrects an offense when using argumentless `zip` without parentheses in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip]
      ^^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      array.zip([]).to_h
    RUBY
  end

  it 'registers and corrects an offense when using argumentless `zip` with parentheses in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip()]
      ^^^^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      array.zip([]).to_h
    RUBY
  end

  it 'reports different offense for Hash[a || b]' do
    expect_offense(<<~RUBY)
      Hash[a || b]
      ^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      (a || b).to_h
    RUBY
  end

  it 'reports different offense for Hash[(a || b)]' do
    expect_offense(<<~RUBY)
      Hash[(a || b)]
      ^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      (a || b).to_h
    RUBY
  end

  it 'reports different offense for Hash[a && b]' do
    expect_offense(<<~RUBY)
      Hash[a && b]
      ^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      (a && b).to_h
    RUBY
  end

  it 'reports different offense for Hash[(a && b)]' do
    expect_offense(<<~RUBY)
      Hash[(a && b)]
      ^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      (a && b).to_h
    RUBY
  end

  it 'registers and corrects an offense when using `zip` with argument in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip([1, 2, 3])]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      array.zip([1, 2, 3]).to_h
    RUBY
  end

  context 'AllowSplatArgument: true' do
    let(:cop_config) { { 'AllowSplatArgument' => true } }

    it 'does not register an offense for unpacked array' do
      expect_no_offenses(<<~RUBY)
        Hash[*ary]
      RUBY
    end
  end

  context 'AllowSplatArgument: false' do
    let(:cop_config) { { 'AllowSplatArgument' => false } }

    it 'reports uncorrectable offense for unpacked array' do
      expect_offense(<<~RUBY)
        Hash[*ary]
        ^^^^^^^^^^ Prefer array_of_pairs.to_h to Hash[*array].
      RUBY

      expect_no_corrections
    end
  end
end
