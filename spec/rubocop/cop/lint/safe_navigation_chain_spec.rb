# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationChain, :config do
  shared_examples 'accepts' do |name, code|
    it "accepts usages of #{name}" do
      expect_no_offenses(code)
    end
  end

  context 'TargetRubyVersion >= 2.3', :ruby23 do
    [
      ['ordinary method chain', 'x.foo.bar.baz'],
      ['ordinary method chain with argument', 'x.foo(x).bar(y).baz(z)'],
      ['method chain with safe navigation only', 'x&.foo&.bar&.baz'],
      ['method chain with safe navigation only with argument',
       'x&.foo(x)&.bar(y)&.baz(z)'],
      ['safe navigation at last only', 'x.foo.bar&.baz'],
      ['safe navigation at last only with argument', 'x.foo(x).bar(y)&.baz(z)'],
      ['safe navigation with == operator', 'x&.foo == bar'],
      ['safe navigation with === operator', 'x&.foo === bar'],
      ['safe navigation with || operator', 'x&.foo || bar'],
      ['safe navigation with && operator', 'x&.foo && bar'],
      ['safe navigation with | operator', 'x&.foo | bar'],
      ['safe navigation with & operator', 'x&.foo & bar'],
      ['safe navigation with `nil?` method', 'x&.foo.nil?'],
      ['safe navigation with `present?` method', 'x&.foo.present?'],
      ['safe navigation with `blank?` method', 'x&.foo.blank?'],
      ['safe navigation with `try` method', 'a&.b.try(:c)'],
      ['safe navigation with assignment method', 'x&.foo = bar'],
      ['safe navigation with self assignment method', 'x&.foo += bar'],
      ['safe navigation with `to_d` method', 'x&.foo.to_d'],
      ['safe navigation with `in?` method', 'x&.foo.in?([:baz, :qux])'],
      ['safe navigation with `+@` method', '+str&.to_i'],
      ['safe navigation with `-@` method', '-str&.to_i']
    ].each do |name, code|
      it_behaves_like 'accepts', name, code
    end

    it 'registers an offense for ordinary method call exists after safe navigation method call' do
      expect_offense(<<~RUBY)
        x&.foo.bar
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar
      RUBY
    end

    it 'registers an offense for ordinary method call exists after ' \
       'safe navigation method call with an argument' do
      expect_offense(<<~RUBY)
        x&.foo(x).bar(y)
                 ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo(x)&.bar(y)
      RUBY
    end

    it 'registers an offense for ordinary method call after a parenthesized safe navigation call' do
      expect_offense(<<~RUBY)
        (x&.foo).bar
                ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        (x&.foo)&.bar
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after safe navigation method call' do
      expect_offense(<<~RUBY)
        something
        x&.foo.bar.baz
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after safe navigation leading dot method call' do
      expect_offense(<<~RUBY)
        x&.foo
         &.bar
         .baz
         ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo
         &.bar
         &.baz
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with an argument' do
      expect_offense(<<~RUBY)
        x&.foo(x).bar(y).baz(z)
                 ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo(x)&.bar(y)&.baz(z)
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block-pass' do
      expect_offense(<<~RUBY)
        something
        x&.select(&:foo).bar
                        ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select(&:foo)&.bar
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block' do
      expect_offense(<<~RUBY)
        something
        x&.select { |x| foo(x) }.bar
                                ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select { |x| foo(x) }&.bar
      RUBY
    end

    it 'registers an offense for safe navigation with < operator' do
      expect_offense(<<~RUBY)
        x&.foo < bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. < bar
      RUBY
    end

    it 'registers an offense for safe navigation with > operator' do
      expect_offense(<<~RUBY)
        x&.foo > bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. > bar
      RUBY
    end

    it 'registers an offense for safe navigation with <= operator' do
      expect_offense(<<~RUBY)
        x&.foo <= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. <= bar
      RUBY
    end

    it 'registers an offense for safe navigation with >= operator' do
      expect_offense(<<~RUBY)
        x&.foo >= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. >= bar
      RUBY
    end

    it 'registers an offense when a safe navigation operator is used with a method call as both the LHS and RHS operands of `&&` for the same receiver' do
      expect_offense(<<~RUBY)
        x&.foo.bar && x&.foo.baz
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar && x&.foo.baz
      RUBY
    end

    it 'does not register an offense when a safe navigation operator is used with a method call as the RHS operand of `&&` for the same receiver' do
      expect_no_offenses(<<~RUBY)
        x&.foo&.bar && x&.foo.baz
      RUBY
    end

    it 'registers an offense when a safe navigation operator is used with a method call as the RHS operand of `&&` for a different receiver' do
      expect_offense(<<~RUBY)
        x&.foo&.bar && y&.foo.baz
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar && y&.foo&.baz
      RUBY
    end

    it 'registers an offense when a safe navigation operator is used with a method call as both the LHS and RHS operands of `||` for the same receiver' do
      expect_offense(<<~RUBY)
        x&.foo.bar || x&.foo.baz
                            ^^^^ Do not chain ordinary method call after safe navigation operator.
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar || x&.foo&.baz
      RUBY
    end

    it 'registers an offense when a safe navigation operator is used with a method call as the RHS operand of `||` for the same receiver' do
      expect_offense(<<~RUBY)
        x&.foo&.bar || x&.foo.baz
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar || x&.foo&.baz
      RUBY
    end

    it 'registers an offense when a safe navigation operator is used with a method call as the RHS operand of `||` for a different receiver' do
      expect_offense(<<~RUBY)
        x&.foo&.bar || y&.foo.baz
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar || y&.foo&.baz
      RUBY
    end

    it 'registers an offense for safe navigation with a method call as an expression of `&&` operand' do
      expect_offense(<<~RUBY)
        do_something && x&.foo.bar
                              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something && x&.foo&.bar
      RUBY
    end

    it 'registers an offense for safe navigation with `>=` operator as an expression of `&&` operand' do
      expect_offense(<<~RUBY)
        do_something && x&.foo >= bar
                              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something && (x&.foo&. >= bar)
      RUBY
    end

    it 'registers an offense for safe navigation with `>=` operator as an expression of `||` operand' do
      expect_offense(<<~RUBY)
        do_something || x&.foo >= bar
                              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something || (x&.foo&. >= bar)
      RUBY
    end

    it 'registers an offense for safe navigation with `>=` operator as an expression of `and` operand' do
      expect_offense(<<~RUBY)
        do_something and x&.foo >= bar
                               ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something and x&.foo&. >= bar
      RUBY
    end

    it 'registers an offense for safe navigation with `>=` operator as an expression of `or` operand' do
      expect_offense(<<~RUBY)
        do_something or x&.foo >= bar
                              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something or x&.foo&. >= bar
      RUBY
    end

    it 'registers an offense for safe navigation with `>=` operator as an expression of comparison method operand' do
      expect_offense(<<~RUBY)
        do_something == x&.foo >= bar
                              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something == (x&.foo&. >= bar)
      RUBY
    end

    it 'registers an offense for safe navigation with + operator' do
      expect_offense(<<~RUBY)
        x&.foo + bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. + bar
      RUBY
    end

    it 'registers an offense for safe navigation with [] operator' do
      expect_offense(<<~RUBY)
        x&.foo[bar]
              ^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[](bar)
      RUBY
    end

    it 'registers an offense for safe navigation with [] operator followed by method chain' do
      expect_offense(<<~RUBY)
        x&.foo[bar].to_s
              ^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[](bar).to_s
      RUBY
    end

    it 'registers an offense for safe navigation with []= operator' do
      expect_offense(<<~RUBY)
        x&.foo[bar] = baz
              ^^^^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[]=(bar, baz)
      RUBY
    end

    it 'registers an offense for [] operator followed by a safe navigation and method chain' do
      expect_offense(<<~RUBY)
        foo[bar]&.x.y
                   ^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        foo[bar]&.x&.y
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `+`' do
      expect_offense(<<~RUBY)
        x + foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x + foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `-`' do
      expect_offense(<<~RUBY)
        x - foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x - foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `*`' do
      expect_offense(<<~RUBY)
        x * foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x * foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `/`' do
      expect_offense(<<~RUBY)
        x / foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x / foo&.bar&.baz
      RUBY
    end

    # NOTE: `foo&.bar` in the true branch is handled by `Lint/RedundantSafeNavigation`.
    it 'does not register an offense when chaining a method call after safe navigation in the if branch of a ternary' do
      expect_no_offenses(<<~RUBY)
        foo&.bar ? foo&.bar - 1 : baz
      RUBY
    end

    it 'registers an offense when chaining a method call after safe navigation in the else branch of a ternary' do
      expect_offense(<<~RUBY)
        foo&.bar ? baz : foo&.bar - 1
                                 ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      # NOTE: The receiver in the else branch may be nil, so chaining could raise `NoMethodError`.
      # Autocorrection is not possible as the intent is ambiguous.
      expect_no_corrections
    end

    it 'registers an offense and corrects when chaining a method call after safe navigation in the else branch of an unrelated ternary' do
      expect_offense(<<~RUBY)
        cond ? baz : user&.team.name
                               ^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        cond ? baz : user&.team&.name
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of a `-` operator when inside an array' do
      expect_offense(<<~RUBY)
        [foo, a&.baz - 1]
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        [foo, (a&.baz&. - 1)]
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of a `-` operator when inside a hash' do
      expect_offense(<<~RUBY)
        { foo: a&.baz - 1 }
                     ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        { foo: (a&.baz&. - 1) }
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is a method argument' do
      expect_offense(<<~RUBY)
        do_something(a&.baz - 1, foo)
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something((a&.baz&. - 1), foo)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the last method argument with a trailing comma' do
      expect_offense(<<~RUBY)
        do_something(
          a&.baz > 1,
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        )
      RUBY

      expect_correction(<<~RUBY)
        do_something(
          (a&.baz&. > 1),
        )
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the sole argument with a trailing comma' do
      expect_offense(<<~RUBY)
        do_something(a&.baz > 1,)
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something((a&.baz&. > 1),)
      RUBY
    end

    it 'corrects safe navigation on the left-hand side of an operator when it is the sole argument with a trailing comma after CRLF line endings' do
      new_source = autocorrect_source("foo\r\nbar\r\ndo_something(a&.baz > 1,)\r\n")

      expect(new_source).to eq("foo\nbar\ndo_something((a&.baz&. > 1),)\n")
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the sole argument of a parenthesized call' do
      expect_offense(<<~RUBY)
        do_something(a&.baz - 1)
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something(a&.baz&. - 1)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the sole argument of a multiline parenthesized call' do
      expect_offense(<<~RUBY)
        do_something(
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        )
      RUBY

      expect_correction(<<~RUBY)
        do_something(
          (a&.baz&. - 1)
        )
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the sole argument of a call without parentheses' do
      expect_offense(<<~RUBY)
        do_something a&.baz - 1
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something a&.baz&. - 1
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is followed by a block argument' do
      expect_offense(<<~RUBY)
        do_something(a&.baz - 1, &block)
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something((a&.baz&. - 1), &block)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the argument of `yield`' do
      expect_offense(<<~RUBY)
        def do_something
          yield a&.baz - 1
                      ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        def do_something
          yield a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the sole argument of an index' do
      expect_offense(<<~RUBY)
        x[a&.baz - 1]
                ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x[(a&.baz&. - 1)]
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator when it is the operand of another operator' do
      expect_offense(<<~RUBY)
        a&.baz + 1 + 2
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        (a&.baz&. + 1)&. + 2
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a `case` subject and a `when` body' do
      expect_offense(<<~RUBY)
        case a&.baz - 1
                   ^^^^ Do not chain ordinary method call after safe navigation operator.
        when 1
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        case a&.baz&. - 1
        when 1
          a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a `while` condition and body' do
      expect_offense(<<~RUBY)
        while a&.baz > 1
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        while a&.baz&. > 1
          a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in `rescue` and `ensure` bodies' do
      expect_offense(<<~RUBY)
        begin
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        rescue
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        ensure
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          a&.baz&. - 1
        rescue
          a&.baz&. - 1
        ensure
          a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a `rescue` modifier value' do
      expect_offense(<<~RUBY)
        x = foo rescue a&.baz - 1
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x = foo rescue (a&.baz&. - 1)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a class body' do
      expect_offense(<<~RUBY)
        class Foo
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an assignment in an `and` operand' do
      expect_offense(<<~RUBY)
        foo and x = a&.baz - 1
                          ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        foo and x = (a&.baz&. - 1)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a ternary branch' do
      expect_offense(<<~RUBY)
        cond ? a&.baz - 1 : foo
                     ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        cond ? (a&.baz&. - 1) : foo
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator inside `&&`' do
      expect_offense(<<~RUBY)
        foo && a&.baz - 1
                     ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        foo && (a&.baz&. - 1)
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an assignment' do
      expect_offense(<<~RUBY)
        x = a&.baz - 1
                  ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x = a&.baz&. - 1
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an assignment in a ternary branch' do
      expect_offense(<<~RUBY)
        cond ? x ||= a&.baz - 1 : foo
                           ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        cond ? x ||= (a&.baz&. - 1) : foo
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an assignment as a method argument' do
      expect_offense(<<~RUBY)
        do_something(x = a&.baz - 1)
                               ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        do_something(x = (a&.baz&. - 1))
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an index of an index assignment' do
      expect_offense(<<~RUBY)
        x[1, a&.baz - 1] = foo
                   ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x[1, (a&.baz&. - 1)] = foo
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an index assignment' do
      expect_offense(<<~RUBY)
        x[1] = a&.baz - 1
                     ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x[1] = a&.baz&. - 1
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in a method body' do
      expect_offense(<<~RUBY)
        def do_something
          a&.baz - 1
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        end
      RUBY

      expect_correction(<<~RUBY)
        def do_something
          a&.baz&. - 1
        end
      RUBY
    end

    it 'registers an offense for safe navigation on the left-hand side of an operator in an `if` condition' do
      expect_offense(<<~RUBY)
        if a&.baz > 1
                 ^^^^ Do not chain ordinary method call after safe navigation operator.
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        if a&.baz&. > 1
          foo
        end
      RUBY
    end

    context 'proper highlighting' do
      it 'when there are methods before' do
        expect_offense(<<~RUBY)
          something
          x&.foo.bar.baz
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        RUBY

        expect_correction(<<~RUBY)
          something
          x&.foo&.bar&.baz
        RUBY
      end

      it 'when there are methods after' do
        expect_offense(<<~RUBY)
          x&.foo.bar.baz
                ^^^^ Do not chain ordinary method call after safe navigation operator.
          something
        RUBY

        expect_correction(<<~RUBY)
          x&.foo&.bar&.baz
          something
        RUBY
      end

      it 'when in a method' do
        expect_offense(<<~RUBY)
          def something
            x&.foo.bar.baz
                  ^^^^ Do not chain ordinary method call after safe navigation operator.
          end
        RUBY

        expect_correction(<<~RUBY)
          def something
            x&.foo&.bar&.baz
          end
        RUBY
      end

      it 'when in a begin' do
        expect_offense(<<~RUBY)
          begin
            x&.foo.bar.baz
                  ^^^^ Do not chain ordinary method call after safe navigation operator.
          end
        RUBY

        expect_correction(<<~RUBY)
          begin
            x&.foo&.bar&.baz
          end
        RUBY
      end

      it 'when used with a modifier if' do
        expect_offense(<<~RUBY)
          x&.foo.bar.baz if something
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        RUBY

        expect_correction(<<~RUBY)
          x&.foo&.bar&.baz if something
        RUBY
      end
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block using numbered parameter' do
      expect_offense(<<~RUBY)
        something
        x&.select { foo(_1) }.bar
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select { foo(_1) }&.bar
      RUBY
    end
  end

  context '>= Ruby 3.4', :ruby34 do
    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block using `it` parameter' do
      expect_offense(<<~RUBY)
        something
        x&.select { foo(it) }.bar
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select { foo(it) }&.bar
      RUBY
    end

    context 'with a method added to `AllowedMethods`' do
      let(:cop_config) { { 'AllowedMethods' => %w[foo] } }

      it 'does not register an offense for the allowed method' do
        expect_no_offenses('x&.bar.foo')
      end

      it 'still registers an offense for a method that is not allowed' do
        expect_offense(<<~RUBY)
          x&.bar.baz
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        RUBY

        expect_correction(<<~RUBY)
          x&.bar&.baz
        RUBY
      end
    end
  end
end
