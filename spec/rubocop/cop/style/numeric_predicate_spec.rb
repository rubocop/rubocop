# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NumericPredicate, :config do
  context 'when configured to enforce numeric predicate methods' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'predicate', 'AutoCorrect' => true }
    end

    context 'when checking if a number is zero' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          number == 0
          ^^^^^^^^^^^ Use `number.zero?` instead of `number == 0`.
          0 == number
          ^^^^^^^^^^^ Use `number.zero?` instead of `0 == number`.
        RUBY
        expect_correction(<<~RUBY)
          number.zero?
          number.zero?
        RUBY
      end

      it 'registers an offense with a complex expression' do
        expect_offense(<<~RUBY)
          foo - 1 == 0
          ^^^^^^^^^^^^ Use `(foo - 1).zero?` instead of `foo - 1 == 0`.
          0 == foo - 1
          ^^^^^^^^^^^^ Use `(foo - 1).zero?` instead of `0 == foo - 1`.
        RUBY
        expect_correction(<<~RUBY)
          (foo - 1).zero?
          (foo - 1).zero?
        RUBY
      end

      it 'allows comparing against a global variable' do
        expect_no_offenses('$CHILD_STATUS == 0')
        expect_no_offenses('0 == $CHILD_STATUS')
      end

      context 'when comparing against a method argument variable' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def m(foo)
              foo == 0
              ^^^^^^^^ Use `foo.zero?` instead of `foo == 0`.
            end
          RUBY
          expect_correction(<<~RUBY)
            def m(foo)
              foo.zero?
            end
          RUBY
        end

        it 'registers an offense with complex expression' do
          expect_offense(<<~RUBY)
            def m(foo)
              foo - 1 == 0
              ^^^^^^^^^^^^ Use `(foo - 1).zero?` instead of `foo - 1 == 0`.
            end
          RUBY
          expect_correction(<<~RUBY)
            def m(foo)
              (foo - 1).zero?
            end
          RUBY
        end
      end
    end

    context 'with checking if a number is not zero' do
      it 'allows comparing against a variable' do
        expect_no_offenses('number != 0')
        expect_no_offenses('0 != number')
      end

      it 'allows comparing against a complex expression' do
        expect_no_offenses('foo - 1 != 0')
        expect_no_offenses('0 != foo - 1')
      end

      it 'allows comparing against a global variable' do
        expect_no_offenses('$CHILD_STATUS != 0')
        expect_no_offenses('0 != $CHILD_STATUS')
      end
    end

    context 'when checking if a number is positive' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          number > 0
          ^^^^^^^^^^ Use `number.positive?` instead of `number > 0`.
        RUBY
        expect_correction(<<~RUBY)
          number.positive?
        RUBY
      end

      it 'registers an offense in yoda condition' do
        expect_offense(<<~RUBY)
          0 < number
          ^^^^^^^^^^ Use `number.positive?` instead of `0 < number`.
        RUBY
        expect_correction(<<~RUBY)
          number.positive?
        RUBY
      end

      context 'with a complex expression' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo - 1 > 0
            ^^^^^^^^^^^ Use `(foo - 1).positive?` instead of `foo - 1 > 0`.
          RUBY
          expect_correction(<<~RUBY)
            (foo - 1).positive?
          RUBY
        end

        it 'registers an offense in yoda condition' do
          expect_offense(<<~RUBY)
            0 < foo - 1
            ^^^^^^^^^^^ Use `(foo - 1).positive?` instead of `0 < foo - 1`.
          RUBY
          expect_correction(<<~RUBY)
            (foo - 1).positive?
          RUBY
        end
      end
    end

    context 'when checking if a number is negative' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          number < 0
          ^^^^^^^^^^ Use `number.negative?` instead of `number < 0`.
        RUBY
        expect_correction(<<~RUBY)
          number.negative?
        RUBY
      end

      it 'registers an offense in yoda condition' do
        expect_offense(<<~RUBY)
          0 > number
          ^^^^^^^^^^ Use `number.negative?` instead of `0 > number`.
        RUBY
        expect_correction(<<~RUBY)
          number.negative?
        RUBY
      end

      context 'with a complex expression' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo - 1 < 0
            ^^^^^^^^^^^ Use `(foo - 1).negative?` instead of `foo - 1 < 0`.
          RUBY
          expect_correction(<<~RUBY)
            (foo - 1).negative?
          RUBY
        end

        it 'registers an offense in yoda condition' do
          expect_offense(<<~RUBY)
            0 > foo - 1
            ^^^^^^^^^^^ Use `(foo - 1).negative?` instead of `0 > foo - 1`.
          RUBY
          expect_correction(<<~RUBY)
            (foo - 1).negative?
          RUBY
        end
      end
    end
  end

  context 'when configured to enforce numeric comparison methods' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'comparison', 'AutoCorrect' => true }
    end

    it 'registers an offense for checking if a number is zero' do
      expect_offense(<<~RUBY)
        number.zero?
        ^^^^^^^^^^^^ Use `number == 0` instead of `number.zero?`.
      RUBY
      expect_correction(<<~RUBY)
        number == 0
      RUBY
    end

    it 'allows checking if a number is not zero' do
      expect_no_offenses('number.nonzero?')
    end

    it 'registers an offense for checking if a number is positive' do
      expect_offense(<<~RUBY)
        number.positive?
        ^^^^^^^^^^^^^^^^ Use `number > 0` instead of `number.positive?`.
      RUBY
      expect_correction(<<~RUBY)
        number > 0
      RUBY
    end

    it 'registers an offense for checking if a number is negative' do
      expect_offense(<<~RUBY)
        number.negative?
        ^^^^^^^^^^^^^^^^ Use `number < 0` instead of `number.negative?`.
      RUBY
      expect_correction(<<~RUBY)
        number < 0
      RUBY
    end
  end

  context 'when there are ignored methods' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'predicate',
        'AutoCorrect' => true,
        'IgnoredMethods' => %w[where]
      }
    end

    context 'simple method call' do
      context '`EnforcedStyle` is `predicate`' do
        let(:cop_config) do
          {
            'EnforcedStyle' => 'predicate',
            'IgnoredMethods' => %w[==]
          }
        end

        it 'allows checking if a number is zero' do
          expect_no_offenses(<<~RUBY)
            if number == 0
              puts 'hello'
            end
          RUBY
        end
      end

      context '`EnforcedStyle` is `comparison`' do
        let(:cop_config) do
          {
            'EnforcedStyle' => 'comparison',
            'IgnoredMethods' => %w[zero?]
          }
        end

        it 'allows checking if a number is zero' do
          expect_no_offenses(<<~RUBY)
            if number.zero?
              puts 'hello'
            end
          RUBY
        end
      end
    end

    context 'in argument' do
      context 'ignored method' do
        it 'allows checking if a number is positive' do
          expect_no_offenses('where(Sequel[:number] > 0)')
        end

        it 'allows checking if a number is negative' do
          expect_no_offenses('where(Sequel[:number] < 0)')
        end
      end

      context 'not ignored method' do
        it 'registers an offense for checking if a number is positive' do
          expect_offense(<<~RUBY)
            exclude(number > 0)
                    ^^^^^^^^^^ Use `number.positive?` instead of `number > 0`.
          RUBY
          expect_correction(<<~RUBY)
            exclude(number.positive?)
          RUBY
        end

        it 'registers an offense for checking if a number is negative' do
          expect_offense(<<~RUBY)
            exclude(number < 0)
                    ^^^^^^^^^^ Use `number.negative?` instead of `number < 0`.
          RUBY
          expect_correction(<<~RUBY)
            exclude(number.negative?)
          RUBY
        end
      end
    end

    context 'in block' do
      context 'ignored method' do
        it 'allows checking if a number is positive' do
          expect_no_offenses('where { table[number] > 0 }')
        end

        it 'allows checking if a number is negative' do
          expect_no_offenses('where { table[number] < 0 }')
        end
      end

      context 'not ignored method' do
        it 'registers an offense for checking if a number is positive' do
          expect_offense(<<~RUBY)
            exclude { number > 0 }
                      ^^^^^^^^^^ Use `number.positive?` instead of `number > 0`.
          RUBY
          expect_correction(<<~RUBY)
            exclude { number.positive? }
          RUBY
        end

        it 'registers an offense for checking if a number is negative' do
          expect_offense(<<~RUBY)
            exclude { number < 0 }
                      ^^^^^^^^^^ Use `number.negative?` instead of `number < 0`.
          RUBY
          expect_correction(<<~RUBY)
            exclude { number.negative? }
          RUBY
        end
      end
    end
  end
end
