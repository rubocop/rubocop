# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantLineContinuation, :config do
  it 'registers an offense when redundant line continuations for define class' do
    expect_offense(<<~'RUBY')
      class Foo \
                ^ Redundant line continuation.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo#{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense when redundant line continuations for define method' do
    expect_offense(<<~'RUBY')
      def foo(bar, \
                   ^ Redundant line continuation.
              baz)
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(bar,#{trailing_whitespace}
              baz)
      end
    RUBY
  end

  it 'registers an offense when redundant line continuations for define class method' do
    expect_offense(<<~'RUBY')
      def self.foo(bar, \
                        ^ Redundant line continuation.
                    baz)
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo(bar,#{trailing_whitespace}
                    baz)
      end
    RUBY
  end

  it 'registers an offense when redundant line continuations for block' do
    expect_offense(<<~'RUBY')
      foo do \
             ^ Redundant line continuation.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      foo do#{trailing_whitespace}
        bar
      end
    RUBY
  end

  it 'registers an offense when redundant line continuations for method chain' do
    expect_offense(<<~'RUBY')
      foo. \
           ^ Redundant line continuation.
        bar

      foo \
          ^ Redundant line continuation.
        .bar \
             ^ Redundant line continuation.
          .baz
    RUBY

    expect_correction(<<~RUBY)
      foo.#{trailing_whitespace}
        bar

      foo#{trailing_whitespace}
        .bar#{trailing_whitespace}
          .baz
    RUBY
  end

  it 'registers an offense when redundant line continuations for method chain with safe navigation' do
    expect_offense(<<~'RUBY')
      foo&. \
            ^ Redundant line continuation.
        bar
    RUBY

    expect_correction(<<~RUBY)
      foo&.#{trailing_whitespace}
        bar
    RUBY
  end

  it 'registers an offense when redundant line continuations for array' do
    expect_offense(<<~'RUBY')
      [foo, \
            ^ Redundant line continuation.
        bar]
    RUBY

    expect_correction(<<~RUBY)
      [foo,#{trailing_whitespace}
        bar]
    RUBY
  end

  it 'registers an offense when redundant line continuations for hash' do
    expect_offense(<<~'RUBY')
      {foo: \
            ^ Redundant line continuation.
        bar}
    RUBY

    expect_correction(<<~RUBY)
      {foo:#{trailing_whitespace}
        bar}
    RUBY
  end

  it 'registers an offense when redundant line continuations for method call' do
    expect_offense(<<~'RUBY')
      foo(bar, \
               ^ Redundant line continuation.
        baz)
    RUBY

    expect_correction(<<~RUBY)
      foo(bar,#{trailing_whitespace}
        baz)
    RUBY
  end

  it 'registers an offense and corrects when using redundant line concatenation for assigning a return value and with argument parentheses' do
    expect_offense(<<~'RUBY')
      foo = do_something( \
                          ^ Redundant line continuation.
        argument)
    RUBY

    expect_correction(<<~RUBY)
      foo = do_something(#{trailing_whitespace}
        argument)
    RUBY
  end

  it 'does not register an offense when line continuations for double quoted string' do
    expect_no_offenses(<<~'RUBY')
      foo = "foo \
        bar"
    RUBY
  end

  it 'does not register an offense when line continuations for single quoted string' do
    expect_no_offenses(<<~'RUBY')
      foo = 'foo \
        bar'
    RUBY
  end

  it 'does not register an offense when line continuations inside comment' do
    expect_no_offenses(<<~'RUBY')
      # foo \
      #  .bar
    RUBY
  end

  it 'does not register an offense when string concatenation' do
    expect_no_offenses(<<~'RUBY')
      foo('bar' \
        'baz')
      foo(bar('string1' \
          'string2')).baz
    RUBY
  end

  it 'does not register an offense when using line concatenation and calling a method without parentheses' do
    expect_no_offenses(<<~'RUBY')
      foo do_something \
        argument
    RUBY
  end

  it 'does not register an offense when using line concatenation and safe navigation calling a method without parentheses' do
    expect_no_offenses(<<~'RUBY')
      foo obj&.do_something \
        argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of method call' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of local variable' do
    expect_no_offenses(<<~'RUBY')
      argument = 42

      foo = do_something \
        argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of instance variable' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        @argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of class variable' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        @@argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of global variable' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        $argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of constant' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        ARGUMENT
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of string literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        'argument'
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of interpolated string literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        "argument#{x}"
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of xstring literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        `argument`
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of symbol literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        :argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of regexp literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        (1..9)
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of integer literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        42
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of float literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        42.0
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of true literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        true
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of false literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        false
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of nil literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        nil
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of self' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        self
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of array literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        []
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of hash literal' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        {}
    RUBY
  end

  it 'does not register an offense when line continuations with arithmetic operator' do
    expect_no_offenses(<<~'RUBY')
      1 \
        + 2 \
          - 3 \
            * 4 \
              / 5  \
                % 6
    RUBY
  end

  it 'does not register an offense when line continuations with &&' do
    expect_no_offenses(<<~'RUBY')
      foo \
        && bar
    RUBY
  end

  it 'does not register an offense when line continuations with ||' do
    expect_no_offenses(<<~'RUBY')
      foo \
        || bar
    RUBY
  end

  it 'does not register an offense when line continuations with ternary operator' do
    expect_no_offenses(<<~'RUBY')
      foo \
        ? bar
          : baz
    RUBY
  end

  it 'does not register an offense when line continuations with method argument' do
    expect_no_offenses(<<~'RUBY')
      some_method \
        (argument)
      some_method \
        argument
    RUBY
  end

  it 'does not register an offense when line continuations with using && for comparison chaining' do
    expect_no_offenses(<<~'RUBY')
      foo == other.foo \
        && bar == other.bar \
        && baz == other.baz
    RUBY
  end

  it 'does not register an offense when line continuations with using || for comparison chaining' do
    expect_no_offenses(<<~'RUBY')
      foo == other.foo \
        || bar == other.bar \
        || baz == other.baz
    RUBY
  end

  it 'does not register an offense when line continuations inside heredoc' do
    expect_no_offenses(<<~'RUBY')
      <<~SQL
        SELECT * FROM foo \
          WHERE bar = 1
      SQL
    RUBY
  end

  it 'does not register an offense when not using line continuations' do
    expect_no_offenses(<<~RUBY)
      foo
        .bar
          .baz
      foo
        &.bar
      [foo,
        bar]
      { foo:
        bar }
      foo(bar,
        baz)
    RUBY
  end
end
