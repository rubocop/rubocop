# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodParameterLineBreak do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects params listed on the first line' do
    expect_offense(<<~RUBY)
      def foo(bar,
              ^^^ Add a line break before the first parameter of a multi-line method parameter list.
        baz)
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(
      bar,
        baz)
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects params on first line ' \
    'of singleton method' do
    expect_offense(<<~RUBY)
      def self.foo(bar,
                   ^^^ Add a line break before the first parameter of a multi-line method parameter list.
        baz)
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo(
      bar,
        baz)
        do_something
      end
    RUBY
  end

  it 'accepts params listed on a single line' do
    expect_no_offenses(<<~RUBY)
      def foo(bar, baz, bing)
        do_something
      end
    RUBY
  end

  it 'accepts params without parens' do
    expect_no_offenses(<<~RUBY)
      def foo bar,
        baz
        do_something
      end
    RUBY
  end

  it 'accepts single-line methods' do
    expect_no_offenses('def foo(bar, baz) ; bing ; end')
  end

  it 'accepts methods without params' do
    expect_no_offenses(<<~RUBY)
      def foo
        bing
      end
    RUBY
  end

  it 'registers an offense and corrects params with default values' do
    expect_offense(<<~RUBY)
      def foo(bar = [],
              ^^^^^^^^ Add a line break before the first parameter of a multi-line method parameter list.
        baz = 2)
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(
      bar = [],
        baz = 2)
        do_something
      end
    RUBY
  end
end
