# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BooleanMemoization, :config do
  it 'registers an offense when using a predicate method' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        return @foo if defined?(@foo)
      @foo = calculate_expensive_thing?
      end
    RUBY
  end

  it 'registers an offense when using a predicate method with argument' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing?(42)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a predicate method with receiver' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= bar.calculate_expensive_thing?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a predicate method with block' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing? { 42 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a predicate method with numblock' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing? { _1 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a predicate method with itblock' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing? { it }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a comparison operator' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing == 42
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using a negation method' do
    expect_offense(<<~RUBY)
      def foo
        @foo ||= !calculate_expensive_thing
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
      end
    RUBY
  end

  it 'registers an offense when using endless method definition', :ruby30 do
    expect_offense(<<~RUBY)
      def foo = @foo ||= calculate_expensive_thing?
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `defined?`-based memoization instead.
    RUBY

    expect_correction(<<~RUBY)
      def foo#{' '}
      return @foo if defined?(@foo)
      @foo = calculate_expensive_thing?
      end
    RUBY
  end

  it 'does not register an offense when using defined?-based memoization' do
    expect_no_offenses(<<~RUBY)
      def foo
        return @foo if defined?(@foo)
        @foo ||= calculate_expensive_thing?
      end
    RUBY
  end

  it 'does not register an offense when not using a predicate method' do
    expect_no_offenses(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing
      end
    RUBY
  end

  it 'does not register an offense when using multiline memoization' do
    expect_no_offenses(<<~RUBY)
      def foo
        @foo ||= begin
          bar
          baz
          qux
        end
      end
    RUBY
  end

  it 'does not register an offense when other nodes exist' do
    expect_no_offenses(<<~RUBY)
      def foo
        @foo ||= calculate_expensive_thing?
        do_something
      end
    RUBY
  end

  it 'does not register an offense when not inside a method' do
    expect_no_offenses(<<~RUBY)
      @foo ||= calculate_expensive_thing?
    RUBY
  end
end
