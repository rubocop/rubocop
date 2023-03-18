# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodArgumentLineBreak, :config do
  context 'args listed on the first line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo(bar,
            ^^^ Add a line break before the first argument of a multi-line method argument list.
          baz)
      RUBY

      expect_correction(<<~RUBY)
        foo(
        bar,
          baz)
      RUBY
    end

    it 'registers an offense and corrects using `super`' do
      expect_offense(<<~RUBY)
        super(bar,
              ^^^ Add a line break before the first argument of a multi-line method argument list.
          baz)
      RUBY

      expect_correction(<<~RUBY)
        super(
        bar,
          baz)
      RUBY
    end

    it 'registers an offense and corrects using safe navigation operator' do
      expect_offense(<<~RUBY)
        receiver&.foo(bar,
                      ^^^ Add a line break before the first argument of a multi-line method argument list.
          baz)
      RUBY

      expect_correction(<<~RUBY)
        receiver&.foo(
        bar,
          baz)
      RUBY
    end
  end

  it 'registers an offense and corrects hash arg spanning multiple lines' do
    expect_offense(<<~RUBY)
      something(3, bar: 1,
                ^ Add a line break before the first argument of a multi-line method argument list.
      baz: 2)
    RUBY

    expect_correction(<<~RUBY)
      something(
      3, bar: 1,
      baz: 2)
    RUBY
  end

  it 'registers an offense and corrects hash arg without a line break before the first pair' do
    expect_offense(<<~RUBY)
      something(bar: 1,
                ^^^^^^ Add a line break before the first argument of a multi-line method argument list.
      baz: 2)
    RUBY

    expect_correction(<<~RUBY)
      something(
      bar: 1,
      baz: 2)
    RUBY
  end

  it 'ignores arguments listed on a single line' do
    expect_no_offenses('foo(bar, baz, bing)')
  end

  it 'ignores kwargs listed on a single line when the arguments are used in `super`' do
    expect_no_offenses('super(foo: 1, bar: 2)')
  end

  it 'ignores arguments without parens' do
    expect_no_offenses(<<~RUBY)
      foo bar,
        baz
    RUBY
  end

  it 'ignores methods without arguments' do
    expect_no_offenses('foo')
  end

  context 'last element can be multiline' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last argument that is a multiline Hash' do
      expect_no_offenses(<<~RUBY)
        foo(bar, {
          a: b
        })
      RUBY
    end

    it 'ignores single argument that is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        foo({
          a: b
        })
      RUBY
    end

    it 'registers and corrects values that are multiline hashes and not the last value' do
      expect_offense(<<~RUBY)
        foo(bar, {
            ^^^ Add a line break before the first argument of a multi-line method argument list.
          a: b
        }, baz)
      RUBY

      expect_correction(<<~RUBY)
        foo(
        bar, {
          a: b
        }, baz)
      RUBY
    end

    it 'registers and corrects last argument that starts on another line' do
      expect_offense(<<~RUBY)
        foo(bar,
            ^^^ Add a line break before the first argument of a multi-line method argument list.
        baz)
      RUBY

      expect_correction(<<~RUBY)
        foo(
        bar,
        baz)
      RUBY
    end
  end
end
