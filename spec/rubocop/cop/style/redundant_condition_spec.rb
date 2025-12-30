# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantCondition, :config do
  context 'when regular condition (if)' do
    it 'accepts different when the condition does not match the branch' do
      expect_no_offenses(<<~RUBY)
        if a
          b
        else
          c
        end
      RUBY
    end

    it 'accepts elsif' do
      expect_no_offenses(<<~RUBY)
        if a
          b
        elsif d
          d
        else
          c
        end
      RUBY
    end

    context 'when condition and if_branch are same' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            c
          end
        RUBY

        expect_correction(<<~RUBY)
          b || c
        RUBY
      end

      it 'registers an offense and does not autocorrect when if branch has a comment' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            # Important note.
            b
          else
            c
          end
        RUBY

        expect_no_corrections
      end

      it 'registers an offense and does not autocorrect when else branch has a comment' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            # Important note.
            c
          end
        RUBY

        expect_no_corrections
      end

      it 'does not register an offense when using assignment by hash key access' do
        expect_no_offenses(<<~RUBY)
          if @cache[key]
            @cache[key]
          else
            @cache[key] = heavy_load[key]
          end
        RUBY
      end

      it 'registers an offense and corrects when `raise` without argument parentheses in `else`' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            raise 'foo'
          end
        RUBY

        expect_correction(<<~RUBY)
          b || raise('foo')
        RUBY
      end

      it 'registers an offense with extra parentheses and modifier `if` in `else`' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            ('foo' if $VERBOSE)
          end
        RUBY

        expect_correction(<<~RUBY)
          b || ('foo' if $VERBOSE)
        RUBY
      end

      it 'registers an offense with double extra parentheses and modifier `if` in `else`' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            (('foo' if $VERBOSE))
          end
        RUBY

        expect_correction(<<~RUBY)
          b || (('foo' if $VERBOSE))
        RUBY
      end

      it 'registers an offense and corrects when a method without argument parentheses in `else`' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            do_something foo, bar, key: :value
          end
        RUBY

        expect_correction(<<~RUBY)
          b || do_something(foo, bar, key: :value)
        RUBY
      end

      it 'registers an offense and corrects when using operator method in `else`' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            c + d
          end
        RUBY

        expect_correction(<<~RUBY)
          b || c + d
        RUBY
      end

      it 'registers an offense and corrects complex one liners' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            (c || d)
          end
        RUBY

        expect_correction(<<~RUBY)
          b || (c || d)
        RUBY
      end

      it 'registers an offense and corrects modifier nodes offense' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            c while d
          end
        RUBY

        expect_correction(<<~RUBY)
          b || (c while d)
        RUBY
      end

      it 'registers an offense and corrects multiline nodes' do
        expect_offense(<<~RUBY)
          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            y(x,
              z)
          end
        RUBY

        expect_correction(<<~RUBY)
          b || y(x,
              z)
        RUBY
      end

      it 'autocorrects when using `<<` method higher precedence than `||` operator' do
        expect_offense(<<~RUBY)
          ary << if foo
                 ^^^^^^ Use double pipes `||` instead.
                   foo
                 else
                   bar
                 end
        RUBY

        expect_correction(<<~RUBY)
          ary << (foo || bar)
        RUBY
      end

      it 'accepts complex else branches' do
        expect_no_offenses(<<~RUBY)
          if b
            b
          else
            c
            d
          end
        RUBY
      end

      it 'accepts an elsif branch' do
        expect_no_offenses(<<~RUBY)
          if a
            a
          elsif cond
            d
          end
        RUBY
      end

      it 'does not register an offense when using modifier `if`' do
        expect_no_offenses(<<~RUBY)
          bar if bar
        RUBY
      end

      it 'does not register an offense when using modifier `unless`' do
        expect_no_offenses(<<~RUBY)
          bar unless bar
        RUBY
      end

      it 'registers an offense and corrects when `if` condition and `then` ' \
         'branch are the same and it has no `else` branch' do
        expect_offense(<<~RUBY)
          if do_something
          ^^^^^^^^^^^^^^^ This condition is not needed.
            do_something
          end
        RUBY

        expect_correction(<<~RUBY)
          do_something
        RUBY
      end

      it 'accepts when using ternary if in `else` branch' do
        expect_no_offenses(<<~RUBY)
          if a
            a
          else
            b ? c : d
          end
        RUBY
      end

      it 'registers an offense and corrects when the else branch contains an irange' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            foo
          else
            1..2
          end
        RUBY

        expect_correction(<<~RUBY)
          foo || (1..2)
        RUBY
      end

      it 'registers an offense and corrects when defined inside method and the branches contains assignment' do
        expect_offense(<<~RUBY)
          def test
            if foo
            ^^^^^^ Use double pipes `||` instead.
              @value = foo
            else
              @value = 'bar'
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def test
            @value = foo || 'bar'
          end
        RUBY
      end

      it 'registers an offense and corrects when the branches contains local variable assignment' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            value = foo
          else
            value = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          value = foo || 'bar'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains instance variable assignment' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            @value = foo
          else
            @value = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          @value = foo || 'bar'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains class variable assignment' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            @@value = foo
          else
            @@value = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          @@value = foo || 'bar'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains global variable assignment' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            $value = foo
          else
            $value = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          $value = foo || 'bar'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains constant assignment' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            CONST = foo
          else
            CONST = 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          CONST = foo || 'bar'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains assignment method' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            test.bar = foo
          else
            test.bar = 'baz'
          end
        RUBY

        expect_correction(<<~RUBY)
          test.bar = foo || 'baz'
        RUBY
      end

      it 'registers an offense and corrects when the branches contains arithmetic operation' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            @value - foo
          else
            @value - 'bar'
          end
        RUBY

        expect_correction(<<~RUBY)
          @value - (foo || 'bar')
        RUBY
      end

      it 'registers an offense and corrects when the branches contains method call' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            bar foo
          else
            bar 1..2
          end
        RUBY

        expect_correction(<<~RUBY)
          bar foo || (1..2)
        RUBY
      end

      it 'registers an offense and corrects when the branches contains method call with braced hash' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            bar foo
          else
            bar({ baz => quux })
          end
        RUBY

        expect_correction(<<~RUBY)
          bar foo || { baz => quux }
        RUBY
      end

      it 'registers an offense and corrects when the branches contains method call with non-braced hash' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            bar foo
          else
            bar baz => quux
          end
        RUBY

        expect_correction(<<~RUBY)
          bar foo || { baz => quux }
        RUBY
      end

      it 'registers an offense and corrects when the branches contains parenthesized method call' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            bar(foo)
          else
            bar(1..2)
          end
        RUBY

        expect_correction(<<~RUBY)
          bar(foo || (1..2))
        RUBY
      end

      it 'registers an offense and corrects when the branches contains empty hash literal argument' do
        expect_offense(<<~RUBY)
          if foo
          ^^^^^^ Use double pipes `||` instead.
            bar(foo)
          else
            bar({})
          end
        RUBY

        expect_correction(<<~RUBY)
          bar(foo || {})
        RUBY
      end

      it 'does not register an offense when the branches contains splat argument' do
        expect_no_offenses(<<~RUBY)
          if foo
            bar(foo)
          else
            bar(*baz)
          end
        RUBY
      end

      it 'does not register an offense when the branches contains double splat argument' do
        expect_no_offenses(<<~RUBY)
          if foo
            bar(foo)
          else
            bar(**baz)
          end
        RUBY
      end

      it 'does not register an offense when the branches contains block argument' do
        expect_no_offenses(<<~RUBY)
          if foo
            bar(foo)
          else
            bar(&baz)
          end
        RUBY
      end

      it 'does not register an offense when the branches contains anonymous splat argument', :ruby32 do
        expect_no_offenses(<<~RUBY)
          def do_something(foo, *)
            if foo
              bar(foo)
            else
              bar(*)
            end
          end
        RUBY
      end

      it 'does not register an offense when the branches contains anonymous double splat argument', :ruby32 do
        expect_no_offenses(<<~RUBY)
          def do_something(foo, **)
            if foo
              bar(foo)
            else
              bar(**)
            end
          end
        RUBY
      end

      it 'does not register an offense when the branches contains anonymous block argument', :ruby31 do
        expect_no_offenses(<<~RUBY)
          def do_something(foo, &)
            if foo
              bar(foo)
            else
              bar(&)
            end
          end
        RUBY
      end

      it 'does not register an offense when the branches contains arguments forwarding', :ruby27 do
        expect_no_offenses(<<~RUBY)
          def do_something(foo, ...)
            if foo
              bar(foo)
            else
              bar(...)
            end
          end
        RUBY
      end

      it 'does not register offenses when using `nil?` and the branches contains assignment' do
        expect_no_offenses(<<~RUBY)
          if foo.nil?
            @value = foo
          else
            @value = 'bar'
          end
        RUBY
      end

      it 'does not register offenses when the branches contains assignment but target not matched' do
        expect_no_offenses(<<~RUBY)
          if foo
            @foo = foo
          else
            @baz = 'quux'
          end
        RUBY
      end

      it 'does not register offenses when using `nil?` and the branches contains method which has multiple arguments' do
        expect_no_offenses(<<~RUBY)
          if foo.nil?
            test.bar foo, bar
          else
            test.bar = 'baz', 'quux'
          end
        RUBY
      end

      it 'does not register offenses when the branches contains hash key access' do
        expect_no_offenses(<<~RUBY)
          if foo
            bar[foo]
          else
            bar[1]
          end
        RUBY
      end

      it 'registers an offense and correct when the branches are the same with the same receivers' do
        expect_offense(<<~RUBY)
          if x
          ^^^^ Use double pipes `||` instead.
            X.find(x)
          else
            X.find(y)
          end
        RUBY

        expect_correction(<<~RUBY)
          X.find(x || y)
        RUBY
      end

      it 'does not register an offense when the branches are the same with different receivers' do
        expect_no_offenses(<<~RUBY)
          if x
            X.find(x)
          else
            Y.find(y)
          end
        RUBY
      end
    end

    context 'when `true` as the true branch' do
      it 'does not register an offense when true is used as the true branch and the condition is a local variable' do
        expect_no_offenses(<<~RUBY)
          variable = do_something

          if variable
            true
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when true is used as the true branch and the condition is an instance variable' do
        expect_no_offenses(<<~RUBY)
          if @variable
            true
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when true is used as the true branch and the condition is a class variable' do
        expect_no_offenses(<<~RUBY)
          if @@variable
            true
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when true is used as the true branch and the condition is a global variable' do
        expect_no_offenses(<<~RUBY)
          if $variable
            true
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when true is used as the true branch and the condition is a constant' do
        expect_no_offenses(<<~RUBY)
          if CONST
            true
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when true is used as the true branch and the condition is not a predicate method' do
        expect_no_offenses(<<~RUBY)
          if a[:key]
            true
          else
            a
          end
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch' do
        expect_offense(<<~RUBY)
          if a.zero?
          ^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            a
          end
        RUBY

        expect_correction(<<~RUBY)
          a.zero? || a
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch and the condition uses safe navigation' do
        expect_offense(<<~RUBY)
          if a&.zero?
          ^^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            a
          end
        RUBY

        expect_correction(<<~RUBY)
          a&.zero? || a
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch and the condition takes arguments' do
        expect_offense(<<~RUBY)
          if foo? arg
          ^^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            bar
          end
        RUBY

        expect_correction(<<~RUBY)
          foo?(arg) || bar
        RUBY
      end

      it 'registers an offense and autocorrects when true is used the true branch and the condition is a parenthesized predicate call with arguments' do
        expect_offense(<<~RUBY)
          if foo?(arg)
          ^^^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            bar
          end
        RUBY

        expect_correction(<<~RUBY)
          foo?(arg) || bar
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch and the condition takes arguments with safe navigation' do
        expect_offense(<<~RUBY)
          if obj&.foo? arg
          ^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            bar
          end
        RUBY

        expect_correction(<<~RUBY)
          obj&.foo?(arg) || bar
        RUBY
      end

      it 'does not register an offense when false is used as the else branch and the condition is not a predicate method' do
        expect_no_offenses(<<~RUBY)
          if !a[:key]
            a
          else
            false
          end
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch and the false branch is a string' do
        expect_offense(<<~RUBY)
          if b.nil?
          ^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            'hello world'
          end
        RUBY

        expect_correction(<<~RUBY)
          b.nil? || 'hello world'
        RUBY
      end

      it 'registers an offense and autocorrects when true is used as the true branch and the false branch is an array' do
        expect_offense(<<~RUBY)
          if c.empty?
          ^^^^^^^^^^^ Use double pipes `||` instead.
            true
          else
            [1, 2, 3]
          end
        RUBY

        expect_correction(<<~RUBY)
          c.empty? || [1, 2, 3]
        RUBY
      end

      context 'when if branch has a comment or else branch has a comment' do
        it 'does not autocorrect when the true branch has a comment after it' do
          expect_offense(<<~RUBY)
            if a.zero?
            ^^^^^^^^^^ Use double pipes `||` instead.
              true # comment
            else
              a
            end
          RUBY

          expect_no_corrections
        end

        it 'does not autocorrect when the true branch has a comment before it' do
          expect_offense(<<~RUBY)
            if a.zero?
            ^^^^^^^^^^ Use double pipes `||` instead.
              # comment
              true
            else
              a
            end
          RUBY

          expect_no_corrections
        end

        it 'does not autocorrect when the false branch has a comment after it' do
          expect_offense(<<~RUBY)
            if a.zero?
            ^^^^^^^^^^ Use double pipes `||` instead.
              true
            else
              a # comment
            end
          RUBY

          expect_no_corrections
        end

        it 'does not autocorrect when the false branch has a comment before it' do
          expect_offense(<<~RUBY)
            if a.zero?
            ^^^^^^^^^^ Use double pipes `||` instead.
              true
            else
              # comment
              a
            end
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'when the true branch is `not true`' do
      it 'does not register an offense when the true branch is a string' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            'true'
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when the true branch is a quoted string' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            "true"
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when the true branch is false' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            false
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when the true branch is a number' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            1
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when there is no else branch' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            true
          else
          end
        RUBY
      end

      it 'does not register an offense when there is no if branch' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
          else
            a
          end
        RUBY
      end

      it 'does not register an offense when there are two different branches' do
        expect_no_offenses(<<~RUBY)
          if a.zero?
            a
          else
            b
          end
        RUBY
      end
    end
  end

  context 'ternary expression (?:)' do
    it 'accepts expressions when the condition and if branch do not match' do
      expect_no_offenses('b ? d : c')
    end

    it 'registers an offense with extra parentheses and modifier `if` in `else`' do
      expect_offense(<<~RUBY)
        b ? b : (raise 'foo' if $VERBOSE)
          ^^^^^ Use double pipes `||` instead.
      RUBY

      expect_correction(<<~RUBY)
        b || (raise 'foo' if $VERBOSE)
      RUBY
    end

    context 'when condition and if_branch are same' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          b ? b : c
            ^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          b || c
        RUBY
      end

      it 'registers an offense and corrects with empty arguments' do
        expect_offense(<<~RUBY)
          test ? test : Proc.new {}
               ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          test || Proc.new {}
        RUBY
      end

      it 'registers an offense and corrects nested vars' do
        expect_offense(<<~RUBY)
          b.x ? b.x : c
              ^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          b.x || c
        RUBY
      end

      it 'registers an offense and corrects class vars' do
        expect_offense(<<~RUBY)
          @b ? @b : c
             ^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          @b || c
        RUBY
      end

      it 'registers an offense and corrects functions' do
        expect_offense(<<~RUBY)
          a = b(x) ? b(x) : c
                   ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          a = b(x) || c
        RUBY
      end

      it 'registers an offense and corrects brackets accesses' do
        expect_offense(<<~RUBY)
          a = b[:x] ? b[:x] : b[:y]
                    ^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          a = b[:x] || b[:y]
        RUBY
      end

      it 'registers an offense and corrects when the else branch contains an irange' do
        expect_offense(<<~RUBY)
          time_period = updated_during ? updated_during : 2.days.ago..Time.now
                                       ^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          time_period = updated_during || (2.days.ago..Time.now)
        RUBY
      end

      it 'registers an offense and corrects when the else branch contains an erange' do
        expect_offense(<<~RUBY)
          time_period = updated_during ? updated_during : 2.days.ago...Time.now
                                       ^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          time_period = updated_during || (2.days.ago...Time.now)
        RUBY
      end

      it 'registers an offense and corrects with ternary expression and the branches contains parenthesized method call' do
        expect_offense(<<~RUBY)
          foo ? bar(foo) : bar(quux)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          bar(foo || quux)
        RUBY
      end

      it 'registers an offense and corrects with ternary expression and the branches contains chained parenthesized method call' do
        expect_offense(<<~RUBY)
          foo ? foo(foo).bar(foo) : foo(foo).bar(quux)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          foo(foo).bar(foo || quux)
        RUBY
      end

      it 'registers an offense and corrects when the else branch contains `rescue`' do
        expect_offense(<<~RUBY)
          if a
          ^^^^ Use double pipes `||` instead.
            a
          else
            b rescue c
          end
        RUBY

        expect_correction(<<~RUBY)
          a || (b rescue c)
        RUBY
      end

      it 'registers an offense and corrects when the else branch contains `and`' do
        expect_offense(<<~RUBY)
          if a
          ^^^^ Use double pipes `||` instead.
            a
          else
            b and c
          end
        RUBY

        expect_correction(<<~RUBY)
          a || (b and c)
        RUBY
      end
    end

    context 'when `true` as the true branch' do
      it 'registers an offense and autocorrects when the true branch is true and the false branch is a variable' do
        expect_offense(<<~RUBY)
          a.zero? ? true : a
                  ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          a.zero? || a
        RUBY
      end

      it 'registers an offense and autocorrects when the true branch is true and the false branch is a number' do
        expect_offense(<<~RUBY)
          a.zero? ? true : 5
                  ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          a.zero? || 5
        RUBY
      end

      it 'registers an offense and autocorrects when the true branch is true and the false branch is a string' do
        expect_offense(<<~RUBY)
          a.zero? ? true : 'a string'
                  ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          a.zero? || 'a string'
        RUBY
      end

      it 'registers an offense and autocorrects when the true branch is true and the false branch is assigned to a variable' do
        expect_offense(<<~RUBY)
          something = a.zero? ? true : a
                              ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          something = a.zero? || a
        RUBY
      end

      it 'registers an offense and autocorrects when the true branch is true and the false branch is an array' do
        expect_offense(<<~RUBY)
          b.nil? ? true : [1, 2, 3]
                 ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          b.nil? || [1, 2, 3]
        RUBY
      end

      it 'registers an offense and autocorrects assignment when the true branch is true and the false branch is a variable' do
        expect_offense(<<~RUBY)
          something = a.nil? ? true : a
                             ^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          something = a.nil? || a
        RUBY
      end
    end

    context 'when the true branch is `not true`' do
      it 'does not register an offense when the true branch is a string' do
        expect_no_offenses(<<~RUBY)
          a.zero? ? 'true' : a
        RUBY
      end

      it 'does not register an offense when the true branch is a quoted string' do
        expect_no_offenses(<<~RUBY)
          a.zero? ? "true" : a
        RUBY
      end

      it 'does not register an offense when the true branch is false' do
        expect_no_offenses(<<~RUBY)
          a.zero? ? false : a
        RUBY
      end

      it 'does not register an offense when the true branch is a number' do
        expect_no_offenses(<<~RUBY)
          a.zero? ? 1 : a
        RUBY
      end

      it 'does not register an offense when the true and false branches are different variables' do
        expect_no_offenses(<<~RUBY)
          a.zero? ? a : b
        RUBY
      end
    end
  end

  context 'when inverted condition (unless)' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        unless a
          b
        else
          c
        end
      RUBY
    end

    context 'when condition and else branch are same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          unless b
          ^^^^^^^^ Use double pipes `||` instead.
            y(x, z)
          else
            b
          end
        RUBY

        expect_correction(<<~RUBY)
          b || y(x, z)
        RUBY
      end

      it 'accepts complex unless branches' do
        expect_no_offenses(<<~RUBY)
          unless b
            c
            d
          else
            b
          end
        RUBY
      end
    end
  end

  context 'when `AllowedMethods: nonzero?`' do
    let(:cop_config) { { 'AllowedMethods' => ['nonzero?'] } }

    it 'does not register an offense when using `nonzero?`' do
      expect_no_offenses(<<~RUBY)
        if a.nonzero?
          true
        else
          false
        end
      RUBY
    end
  end
end
