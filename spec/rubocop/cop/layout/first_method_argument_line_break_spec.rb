# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodArgumentLineBreak do
  subject(:cop) { described_class.new }

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

  it 'registers an offense and corrects hash arg ' \
    'without a line break before the first pair' do
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

  it 'ignores arguments without parens' do
    expect_no_offenses(<<~RUBY)
      foo bar,
        baz
    RUBY
  end

  it 'ignores methods without arguments' do
    expect_no_offenses('foo')
  end
end
