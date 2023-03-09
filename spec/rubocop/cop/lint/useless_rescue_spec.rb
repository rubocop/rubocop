# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessRescue, :config do
  it 'registers an offense when single `rescue` which only anonymously reraises' do
    expect_offense(<<~RUBY)
      def foo
        do_something
      rescue
      ^^^^^^ Useless `rescue` detected.
        raise
      end
    RUBY
  end

  it 'registers an offense when single `rescue` which only reraises exception variable' do
    expect_offense(<<~RUBY)
      def foo
        do_something
      rescue => e
      ^^^^^^^^^^^ Useless `rescue` detected.
        raise e
      end
    RUBY

    expect_offense(<<~RUBY)
      def foo
        do_something
      rescue
      ^^^^^^ Useless `rescue` detected.
        raise $!
      end
    RUBY

    expect_offense(<<~RUBY)
      def foo
        do_something
      rescue
      ^^^^^^ Useless `rescue` detected.
        raise $ERROR_INFO
      end
    RUBY
  end

  it 'does not register an offense when `rescue` not only reraises' do
    expect_no_offenses(<<~RUBY)
      def foo
        do_something
      rescue
        do_cleanup
        raise e
      end
    RUBY
  end

  it 'does not register an offense when `rescue` only reraises but not exception variable' do
    expect_no_offenses(<<~RUBY)
      def foo
        do_something
      rescue => e
        raise x
      end
    RUBY
  end

  it 'does not register an offense when `rescue` does not exception variable and `ensure` has empty body' do
    expect_no_offenses(<<~RUBY)
      def foo
      rescue => e
      ensure
      end
    RUBY
  end

  it 'does not register an offense when using exception variable in `ensure` clause' do
    expect_no_offenses(<<~RUBY)
      def foo
        do_something
      rescue => e
        raise
      ensure
        do_something(e)
      end
    RUBY
  end

  it 'registers an offense when multiple `rescue`s and last is only reraises' do
    expect_offense(<<~RUBY)
      def foo
        do_something
      rescue ArgumentError
        # noop
      rescue
      ^^^^^^ Useless `rescue` detected.
        raise
      end
    RUBY
  end

  it 'does not register an offense when multiple `rescue`s and not last is only reraises' do
    expect_no_offenses(<<~RUBY)
      def foo
        do_something
      rescue ArgumentError
        raise
      rescue
        # noop
      end
    RUBY
  end

  it 'does not register an offense when using `Thread#raise` in `rescue` clause' do
    expect_no_offenses(<<~RUBY)
      def foo
        do_something
      rescue
        Thread.current.raise
      end
    RUBY
  end

  it 'does not register an offense when using modifier `rescue`' do
    expect_no_offenses(<<~RUBY)
      do_something rescue nil
    RUBY
  end
end
