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

      it 'registers an offense and corrects when using modifier if' do
        expect_offense(<<~RUBY)
          bar if bar
          ^^^^^^^^^^ This condition is not needed.
        RUBY

        expect_correction(<<~RUBY)
          bar
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

      it 'registers an offense and corrects when the branches contains assignment' do
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
  end

  context 'ternary expression (?:)' do
    it 'accepts expressions when the condition and if branch do not match' do
      expect_no_offenses('b ? d : c')
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
end
