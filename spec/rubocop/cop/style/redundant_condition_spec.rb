# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantCondition do
  subject(:cop) { described_class.new }

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

      it 'auto-corrects when using `<<` method higher precedence ' \
         'than `||` operator' do
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

      it 'registers an offense and corrects when the else branch ' \
        'contains an irange' do
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

      it 'registers an offense and corrects when the else branch ' \
        'contains an irange' do
        expect_offense(<<~RUBY)
          time_period = updated_during ? updated_during : 2.days.ago..Time.now
                                       ^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          time_period = updated_during || (2.days.ago..Time.now)
        RUBY
      end

      it 'registers an offense and corrects when the else branch ' \
        'contains an erange' do
        expect_offense(<<~RUBY)
          time_period = updated_during ? updated_during : 2.days.ago...Time.now
                                       ^^^^^^^^^^^^^^^^^^ Use double pipes `||` instead.
        RUBY

        expect_correction(<<~RUBY)
          time_period = updated_during || (2.days.ago...Time.now)
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
