# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashConversion, :config do
  it 'reports an offense for single-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[ary]
      ^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      ary.to_h
    RUBY
  end

  it 'reports different offense for multi-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a, b, c, d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {a => b, c => d}
    RUBY
  end

  it 'does not register an offense for a splat argument' do
    # A splat can expand to any number of elements, so no literal hash can be built.
    expect_no_offenses(<<~RUBY)
      Hash[*ary, x]
    RUBY
  end

  it 'reports different offense for hash argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a: b, c: d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[key: value, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {a: b, c: d}
    RUBY
  end

  it 'reports different offense for hash argument Hash[] as a method argument with parentheses' do
    expect_offense(<<~RUBY)
      do_something(Hash[a: b, c: d], 42)
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[key: value, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      do_something({a: b, c: d}, 42)
    RUBY
  end

  it 'reports different offense for hash argument Hash[] as a method argument without parentheses' do
    expect_offense(<<~RUBY)
      do_something Hash[a: b, c: d], 42
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[key: value, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      do_something({a: b, c: d}, 42)
    RUBY
  end

  it 'reports different offense for empty Hash[]' do
    expect_offense(<<~RUBY)
      Hash[]
      ^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {}
    RUBY
  end

  it 'registers and corrects an offense when using multi-argument `Hash[]` as a method argument' do
    expect_offense(<<~RUBY)
      do_something Hash[a, b, c, d], arg
                   ^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      do_something({a => b, c => d}, arg)
    RUBY
  end

  it 'does not try to correct multi-argument Hash with odd number of arguments' do
    expect_offense(<<~RUBY)
      Hash[a, b, c]
      ^^^^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_no_corrections
  end

  it 'wraps complex statements in parens if needed' do
    expect_offense(<<~RUBY)
      Hash[a.foo :bar]
      ^^^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      (a.foo :bar).to_h
    RUBY
  end

  it 'registers and corrects an offense when using argumentless `zip` without parentheses in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip]
      ^^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      array.zip([]).to_h
    RUBY
  end

  it 'registers and corrects an offense when using argumentless `zip` with parentheses in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip()]
      ^^^^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      array.zip([]).to_h
    RUBY
  end

  it 'reports different offense for Hash[a || b]' do
    expect_offense(<<~RUBY)
      Hash[a || b]
      ^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      (a || b).to_h
    RUBY
  end

  it 'reports different offense for Hash[(a || b)]' do
    expect_offense(<<~RUBY)
      Hash[(a || b)]
      ^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      (a || b).to_h
    RUBY
  end

  it 'reports different offense for Hash[a && b]' do
    expect_offense(<<~RUBY)
      Hash[a && b]
      ^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      (a && b).to_h
    RUBY
  end

  it 'reports different offense for Hash[(a && b)]' do
    expect_offense(<<~RUBY)
      Hash[(a && b)]
      ^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      (a && b).to_h
    RUBY
  end

  it 'registers and corrects an offense when using `zip` with argument in `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[array.zip([1, 2, 3])]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      array.zip([1, 2, 3]).to_h
    RUBY
  end

  it 'reports an offense when using nested `Hash[]` without arguments' do
    expect_offense(<<~RUBY)
      Hash[Hash[]]
      ^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      Hash[].to_h
    RUBY
  end

  it 'reports an offense when using nested `Hash[]` with arguments' do
    expect_offense(<<~RUBY)
      Hash[Hash[k, v]]
      ^^^^^^^^^^^^^^^^ Prefer `ary.to_h` to `Hash[ary]`.
    RUBY

    expect_correction(<<~RUBY)
      Hash[k, v].to_h
    RUBY
  end

  it 'registers an offense and corrects nested `Hash[]` calls with multiple arguments' do
    expect_offense(<<~RUBY)
      Hash[1, Hash[k, v]]
      ^^^^^^^^^^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {1 => Hash[k, v]}
    RUBY
  end

  it 'reports an offense for `Hash[].to_h`' do
    expect_offense(<<~RUBY)
      Hash[].to_h
      ^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {}.to_h
    RUBY
  end

  it 'does not add parentheses to a method called on multi-argument `Hash[]`' do
    expect_offense(<<~RUBY)
      Hash[a, b].size
      ^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      {a => b}.size
    RUBY
  end

  it 'does not add parentheses to a unary operator called on hash argument `Hash[]`' do
    expect_offense(<<~RUBY)
      !Hash[a => b]
       ^^^^^^^^^^^^ Prefer literal hash to `Hash[key: value, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      !{a => b}
    RUBY
  end

  it 'adds parentheses when multi-argument `Hash[]` is an argument of `to_h`' do
    expect_offense(<<~RUBY)
      to_h Hash[a, b]
           ^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      to_h({a => b})
    RUBY
  end

  it 'does not add parentheses when multi-argument `Hash[]` is an index argument' do
    expect_offense(<<~RUBY)
      foo[Hash[a, b]]
          ^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      foo[{a => b}]
    RUBY
  end

  it 'does not add parentheses when hash argument `Hash[]` is assigned with a setter' do
    expect_offense(<<~RUBY)
      foo.bar = Hash[a => b]
                ^^^^^^^^^^^^ Prefer literal hash to `Hash[key: value, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar = {a => b}
    RUBY
  end

  it 'does not add parentheses when multi-argument `Hash[]` is an operand of a binary operator' do
    expect_offense(<<~RUBY)
      foo == Hash[a, b]
             ^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      foo == {a => b}
    RUBY
  end

  it 'adds parentheses when multi-argument `Hash[]` is an argument of an operator method called with a dot' do
    expect_offense(<<~RUBY)
      foo.[] Hash[a, b]
             ^^^^^^^^^^ Prefer literal hash to `Hash[arg1, arg2, ...]`.
    RUBY

    expect_correction(<<~RUBY)
      foo.[]({a => b})
    RUBY
  end

  context 'AllowSplatArgument: true' do
    let(:cop_config) { { 'AllowSplatArgument' => true } }

    it 'does not register an offense for unpacked array' do
      expect_no_offenses(<<~RUBY)
        Hash[*ary]
      RUBY
    end

    it 'does not register an offense for an anonymous splat (`*`)', :ruby32 do
      expect_no_offenses(<<~RUBY)
        def foo(*)
          Hash[*]
        end
      RUBY
    end
  end

  context 'AllowSplatArgument: false' do
    let(:cop_config) { { 'AllowSplatArgument' => false } }

    it 'reports uncorrectable offense for unpacked array' do
      expect_offense(<<~RUBY)
        Hash[*ary]
        ^^^^^^^^^^ Prefer `array_of_pairs.to_h` to `Hash[*array]`.
      RUBY

      expect_no_corrections
    end

    it 'reports uncorrectable offense for an anonymous splat (`*`)', :ruby32 do
      expect_offense(<<~RUBY)
        def foo(*)
          Hash[*]
          ^^^^^^^ Prefer `array_of_pairs.to_h` to `Hash[*array]`.
        end
      RUBY

      expect_no_corrections
    end
  end
end
