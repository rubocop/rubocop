# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::GlobalStdStream, :config do
  it 'registers an offense and corrects when using std stream as const' do
    expect_offense(<<~RUBY)
      STDOUT.puts('hello')
      ^^^^^^ Use `$stdout` instead of `STDOUT`.

      hash = { out: STDOUT, key: value }
                    ^^^^^^ Use `$stdout` instead of `STDOUT`.

      def m(out = STDOUT)
                  ^^^^^^ Use `$stdout` instead of `STDOUT`.
        out.puts('hello')
      end
    RUBY

    expect_correction(<<~RUBY)
      $stdout.puts('hello')

      hash = { out: $stdout, key: value }

      def m(out = $stdout)
        out.puts('hello')
      end
    RUBY
  end

  it 'registers an offense when using redundant constant base' do
    expect_offense(<<~RUBY)
      ::STDOUT.puts('hello')
      ^^^^^^^^ Use `$stdout` instead of `STDOUT`.
    RUBY

    expect_correction(<<~RUBY)
      $stdout.puts('hello')
    RUBY
  end

  it 'does not register an offense when using non std stream const' do
    expect_no_offenses(<<~RUBY)
      SOME_CONST.puts('hello')
    RUBY
  end

  it 'does not register an offense when assigning std stream const to std stream gvar' do
    expect_no_offenses(<<~RUBY)
      $stdin = STDIN
    RUBY
  end

  it 'does not register an offense when assigning other const to std stream gvar' do
    expect_no_offenses(<<~RUBY)
      $stdin = SOME_CONST
    RUBY
  end

  it 'does not register an offense when using namespaced constant' do
    expect_no_offenses(<<~RUBY)
      Foo::STDOUT.puts('hello')
      Foo::Bar::STDOUT.puts('hello')
      ::Foo::STDOUT.puts('hello')
      ::Foo::BaR::STDOUT.puts('hello')
      foo::STDOUT.puts('hello')
    RUBY
  end
end
