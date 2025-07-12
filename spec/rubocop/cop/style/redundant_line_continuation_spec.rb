# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantLineContinuation, :config do
  context 'when a line continuation precedes the arguments to an unparenthesized method call' do
    shared_examples 'no offense' do |argument|
      it "does not register an offense when the first argument is `#{argument}`" do
        expect_no_offenses(<<~RUBY)
          foo \\
            #{argument}
        RUBY
      end

      it "does not register an offense for `super` when the first argument is `#{argument}`" do
        expect_no_offenses(<<~RUBY)
          super \\
            #{argument}
        RUBY
      end
    end

    shared_examples 'no forwarding offense' do |argument, *metadata|
      it "does not register an offense when the first argument is `#{argument}", *metadata do
        expect_no_offenses(<<~RUBY)
          def a(#{argument})
            b \\
              #{argument}; # the semicolon is necessary or ruby cannot parse
          end
        RUBY
      end

      it "does not register an offense with superwhen the first argument is `#{argument}", *metadata do
        expect_no_offenses(<<~RUBY)
          def a(#{argument})
            super \\
              #{argument}; # the semicolon is necessary or ruby cannot parse
          end
        RUBY
      end
    end

    it_behaves_like 'no offense', '"string"'
    it_behaves_like 'no offense', '"#{dynamic string}"'
    it_behaves_like 'no offense', '`xstring`'
    it_behaves_like 'no offense', ':symbol'
    it_behaves_like 'no offense', '?c'
    it_behaves_like 'no offense', '123'
    it_behaves_like 'no offense', 'bar'
    it_behaves_like 'no offense', '!bar'
    it_behaves_like 'no offense', '..5'
    it_behaves_like 'no offense', '...5'
    it_behaves_like 'no offense', '~5'
    it_behaves_like 'no offense', '->() {}'
    it_behaves_like 'no offense', 'proc {}'
    it_behaves_like 'no offense', '*bar'
    it_behaves_like 'no offense', '**bar'
    it_behaves_like 'no offense', '&block'
    it_behaves_like 'no offense', '+1'
    it_behaves_like 'no offense', '-1'
    it_behaves_like 'no offense', '+bar'
    it_behaves_like 'no offense', '-bar'
    it_behaves_like 'no offense', '/bar/'
    it_behaves_like 'no offense', '%[bar]'
    it_behaves_like 'no offense', '%w[bar]'
    it_behaves_like 'no offense', '%W[bar]'
    it_behaves_like 'no offense', '%i[bar]'
    it_behaves_like 'no offense', '%I[bar]'
    it_behaves_like 'no offense', '%r[bar]'
    it_behaves_like 'no offense', '%x[bar]'
    it_behaves_like 'no offense', '%s[bar]'
    it_behaves_like 'no offense', 'defined?(bar)'

    it_behaves_like 'no forwarding offense', '...'
    it_behaves_like 'no forwarding offense', '&', :ruby31
    it_behaves_like 'no forwarding offense', '*', :ruby32
    it_behaves_like 'no forwarding offense', '**', :ruby32
  end

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

  it 'registers an offense when redundant line continuations for a block are used, ' \
     'especially without parentheses around first argument' do
    expect_offense(<<~'RUBY')
      let :foo do \
                  ^ Redundant line continuation.
        foo(bar, \
                 ^ Redundant line continuation.
            baz)
      end
    RUBY

    expect_correction(<<~RUBY)
      let :foo do#{trailing_whitespace}
        foo(bar,#{trailing_whitespace}
            baz)
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

  it 'does not register an offense when line continuations involve `return` with a return value' do
    expect_no_offenses(<<~'RUBY')
      return \
        foo
    RUBY
  end

  it 'registers an offense when line continuations involve `return` with a parenthesized return value' do
    expect_offense(<<~'RUBY')
      return(\
             ^ Redundant line continuation.
        foo
      )
    RUBY

    expect_correction(<<~RUBY)
      return(
        foo
      )
    RUBY
  end

  it 'does not register an offense when line continuations involve `break` with a return value' do
    expect_no_offenses(<<~'RUBY')
      foo do
        break \
          bar
      end
    RUBY
  end

  it 'does not register an offense when line continuations involve `next` with a return value' do
    expect_no_offenses(<<~'RUBY')
      foo do
        next \
          bar
      end
    RUBY
  end

  it 'does not register an offense when line continuations involve `yield` with a return value' do
    expect_no_offenses(<<~'RUBY')
      def foo
        yield \
          bar
      end
    RUBY
  end

  it 'registers an offense when line continuations with `if`' do
    expect_offense(<<~'RUBY')
      if foo \
             ^ Redundant line continuation.
      then bar
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo#{trailing_whitespace}
      then bar
      end
    RUBY
  end

  it 'does not register an offense when line continuations with `if` modifier' do
    expect_no_offenses(<<~'RUBY')
      bar \
        if foo
    RUBY
  end

  it 'does not register an offense when line continuations with `unless` modifier' do
    expect_no_offenses(<<~'RUBY')
      bar \
        unless foo
    RUBY
  end

  it 'does not register an offense when line continuations with `while` modifier' do
    expect_no_offenses(<<~'RUBY')
      bar \
        while foo
    RUBY
  end

  it 'does not register an offense when line continuations with `until` modifier' do
    expect_no_offenses(<<~'RUBY')
      bar \
        until foo
    RUBY
  end

  it 'does not register an offense when line continuations with `rescue` modifier' do
    expect_no_offenses(<<~'RUBY')
      bar \
        rescue foo
    RUBY
  end

  it 'does not register an offense when required line continuations for `&&` is used with an assignment after a line break' do
    expect_no_offenses(<<~'RUBY')
      if foo \
        && (bar = baz)
      end
    RUBY
  end

  it 'does not register an offense when required line continuations for multiline leading dot method chain with an empty line' do
    expect_no_offenses(<<~'RUBY')
      obj
       .foo(42) \

       .bar
    RUBY
  end

  it 'does not register an offense when required line continuations for multiline leading dot safe navigation method chain with an empty line' do
    expect_no_offenses(<<~'RUBY')
      obj
       &.foo(42) \

       .bar
    RUBY
  end

  it 'does not register an offense when required line continuations for multiline leading dot method chain with a blank line' do
    expect_no_offenses(<<~RUBY)
      obj
       .foo(42) \\
      #{trailing_whitespace}
       .bar
    RUBY
  end

  it 'registers an offense when redundant line continuations for multiline leading dot method chain without an empty line' do
    expect_offense(<<~'RUBY')
      obj
       .foo(42) \
                ^ Redundant line continuation.
       .bar
    RUBY

    expect_correction(<<~RUBY)
      obj
       .foo(42)#{trailing_whitespace}
       .bar
    RUBY
  end

  it 'registers an offense when redundant line continuations for multiline trailing dot method chain with an empty line' do
    expect_offense(<<~'RUBY')
      obj.
       foo(42). \
                ^ Redundant line continuation.

       bar
    RUBY

    expect_correction(<<~RUBY)
      obj.
       foo(42).#{trailing_whitespace}

       bar
    RUBY
  end

  it 'registers an offense when redundant line continuations for multiline trailing dot method chain without an empty line' do
    expect_offense(<<~'RUBY')
      obj.
       foo(42). \
                ^ Redundant line continuation.
       bar
    RUBY

    expect_correction(<<~RUBY)
      obj.
       foo(42).#{trailing_whitespace}
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
      class Foo
        # foo \
        #   bar
      end
    RUBY
  end

  it 'does not register an offense for a backslash in a comment at EOF' do
    expect_no_offenses(<<~'RUBY')
      foo # \
    RUBY
  end

  it 'does not register an offense for string concatenation with single quotes' do
    expect_no_offenses(<<~'RUBY')
      'bar' \
        'baz'
    RUBY
  end

  it 'does not register an offense for string concatenation with double quotes' do
    expect_no_offenses(<<~'RUBY')
      "bar" \
        "baz"
    RUBY
  end

  it 'does not register an offense for string concatenation inside a method call' do
    expect_no_offenses(<<~'RUBY')
      foo('bar' \
        'baz')
      foo(bar('string1' \
          'string2')).baz
    RUBY
  end

  it 'registers an offense for an interpolated string argument followed by line continuation' do
    expect_offense(<<~'RUBY')
      foo("#{bar}", \
                    ^ Redundant line continuation.
        baz)
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

  it 'does not register an offense when using line concatenation and calling a method with keyword arguments without parentheses' do
    expect_no_offenses(<<~'RUBY')
      foo.bar do_something \
        key: value
    RUBY
  end

  it 'does not register an offense when using line concatenation and calling a method without parentheses in multiple expression block' do
    expect_no_offenses(<<~'RUBY')
      foo do
        bar \
          key: value

        baz
      end
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of method call' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        argument
    RUBY
  end

  it 'does not register an offense when using line concatenation for assigning a return value and without hash argument parentheses of method call' do
    expect_no_offenses(<<~'RUBY')
      foo.bar = do_something \
        key: value
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

  it 'does not register an offense when using line concatenation for assigning a return value and without argument parentheses of constant base' do
    expect_no_offenses(<<~'RUBY')
      foo = do_something \
        ::ARGUMENT
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

  it 'does not register an offense when a line continuation precedes an arithmetic operator' do
    expect_no_offenses(<<~'RUBY')
      1 \
        + 2 \
          - 3 \
            * 4 \
              / 5  \
                % 6 \
                  ** 7
    RUBY
  end

  it 'does not register an offense when a line continuation precedes a bitwise operator' do
    expect_no_offenses(<<~'RUBY')
      1 \
        & 2 \
          | 3 \
            ^ 4
    RUBY
  end

  it 'does not register an offense when line continuations with comparison operator and the LHS is wrapped in parentheses' do
    expect_no_offenses(<<~'RUBY')
      (
        42) \
        == bar
    RUBY
  end

  it 'does not register an offense when line continuations with comparison operator and the LHS is wrapped in brackets' do
    expect_no_offenses(<<~'RUBY')
      [
        42] \
        == bar
    RUBY
  end

  it 'does not register an offense when line continuations with comparison operator and the LHS is wrapped in braces' do
    expect_no_offenses(<<~'RUBY')
      {
        k: :v} \
        == bar
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

  it 'does not register an offense when line continuations with `&&` in assignments' do
    expect_no_offenses(<<~'RUBY')
      foo = bar\
        && baz
    RUBY
  end

  it 'does not register an offense when line continuations with `||` in assignments' do
    expect_no_offenses(<<~'RUBY')
      foo = bar\
        || baz
    RUBY
  end

  it 'does not register an offense when line continuations with `&&` in method definition' do
    expect_no_offenses(<<~'RUBY')
      def do_something
        foo \
          && bar
      end
    RUBY
  end

  it 'does not register an offense when line continuations with `||` in method definition' do
    expect_no_offenses(<<~'RUBY')
      def do_something
        foo \
          || bar
      end
    RUBY
  end

  it 'registers an offense for an extra continuation after a required continuation' do
    expect_offense(<<~'RUBY')
      def do_something
        foo \
          || bar \
                 ^ Redundant line continuation.
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_something
        foo \\
          || bar#{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense for a redundant continuation following a required continuation in separate blocks' do
    expect_offense(<<~'RUBY')
      x do
        foo bar \
          baz
      end

      y do
        foo(bar, \
                 ^ Redundant line continuation.
          baz)
      end
    RUBY

    expect_correction(<<~RUBY)
      x do
        foo bar \\
          baz
      end

      y do
        foo(bar,#{trailing_whitespace}
          baz)
      end
    RUBY
  end

  it 'registers an offense for an redundant continuation on a statement preceding a required continuation inside the same begin node' do
    expect_offense(<<~'RUBY')
      foo(bar, \
               ^ Redundant line continuation.
        baz)

      foo bar \
        baz
    RUBY

    expect_correction(<<~RUBY)
      foo(bar,#{trailing_whitespace}
        baz)

      foo bar \\
        baz
    RUBY
  end

  it 'registers an offense for an redundant continuation on a statement following a required continuation inside the same begin node' do
    expect_offense(<<~'RUBY')
      foo bar \
        baz

      foo(bar, \
               ^ Redundant line continuation.
        baz)
    RUBY

    expect_correction(<<~RUBY)
      foo bar \\
        baz

      foo(bar,#{trailing_whitespace}
        baz)
    RUBY
  end

  it 'registers an offense for multiple redundant continuations inside the same begin node' do
    expect_offense(<<~'RUBY')
      foo(bar, \
               ^ Redundant line continuation.
        baz)

      foo(bar, \
               ^ Redundant line continuation.
        baz)
    RUBY

    expect_correction(<<~RUBY)
      foo(bar,#{trailing_whitespace}
        baz)

      foo(bar,#{trailing_whitespace}
        baz)
    RUBY
  end

  it 'does not register an offense for multiple required continuations inside the same begin node' do
    expect_no_offenses(<<~'RUBY')
      foo bar \
        baz

      foo bar \
        baz
    RUBY
  end

  it 'does not register an offense when multi-line continuations with &' do
    expect_no_offenses(<<~'RUBY')
      foo \
        & bar \
        & baz
    RUBY
  end

  it 'does not register an offense when multi-line continuations with |' do
    expect_no_offenses(<<~'RUBY')
      foo \
        | bar \
        | baz
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

  it 'does not register an offense for a line continuation with a method definition as a method argument' do
    expect_no_offenses(<<~'RUBY')
      class Foo
        memoize \
        def do_something
        end
      end
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

  it 'does not register an offense when line continuations with `&&` in method definition and before a destructuring assignment' do
    expect_no_offenses(<<~'RUBY')
      var, = *foo

      bar \
        && baz
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

  it 'registers an offense when there is a line continuation at the end of Ruby code' do
    expect_offense(<<~'RUBY')
      foo \
          ^ Redundant line continuation.
    RUBY

    expect_correction(<<~RUBY)
      foo#{trailing_whitespace}
    RUBY
  end

  it 'registers an offense when there is a line continuation at the end of Ruby code followed by `__END__` data' do
    expect_offense(<<~'RUBY')
      foo \
          ^ Redundant line continuation.

      __END__
      data \
    RUBY

    expect_correction(<<~RUBY)
      foo#{trailing_whitespace}

      __END__
      data \\
    RUBY
  end

  it 'registers an offense when there is a line continuation inside a method call followed by a percent array' do
    expect_offense(<<~'RUBY')
      foo(bar, \
               ^ Redundant line continuation.
        %i[baz quux])
    RUBY
  end

  it 'registers an offense for a method call with a line continuation and no following arguments' do
    expect_offense(<<~'RUBY')
      def foo
        bar \
            ^ Redundant line continuation.
      end
    RUBY
  end

  it 'registers an offense for `super` with a line continuation and no following arguments' do
    expect_offense(<<~'RUBY')
      def foo
        super \
              ^ Redundant line continuation.
      end
    RUBY
  end

  it 'registers an offense for multiline assignment with a line continuation' do
    expect_offense(<<~'RUBY')
      a, b, \
            ^ Redundant line continuation.
        c = [1, 2, 3]
    RUBY

    expect_correction(<<~RUBY)
      a, b,#{trailing_whitespace}
        c = [1, 2, 3]
    RUBY
  end
end
