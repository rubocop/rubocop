# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BitwisePredicate, :config do
  context 'when checking any set bits' do
    context 'when Ruby >= 2.5', :ruby25 do
      it 'registers an offense when using `&` in conjunction with `predicate` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags).positive?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.anybits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.anybits?(flags)
        RUBY
      end

      it 'registers an offense when using `&` in conjunction with `> 0` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags) > 0
          ^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.anybits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.anybits?(flags)
        RUBY
      end

      it 'registers an offense when using `&` in conjunction with `>= 1` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags) >= 1
          ^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.anybits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.anybits?(flags)
        RUBY
      end

      it 'registers an offense when using `&` in conjunction with `!= 0` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags) != 0
          ^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.anybits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.anybits?(flags)
        RUBY
      end

      it 'does not register an offense when using `anybits?` method' do
        expect_no_offenses(<<~RUBY)
          variable.anybits?(flags)
        RUBY
      end

      it 'does not register an offense when using `&` in conjunction with `> 1` for comparisons' do
        expect_no_offenses(<<~RUBY)
          (variable & flags) > 1
        RUBY
      end

      it 'does not register an offense when comparing with no parentheses' do
        expect_no_offenses(<<~RUBY)
          foo == bar
        RUBY
      end
    end

    context 'when Ruby <= 2.4', :ruby24, unsupported_on: :prism do
      it 'does not register an offense when using `&` in conjunction with `predicate` for comparisons' do
        expect_no_offenses(<<~RUBY)
          (variable & flags).positive?
        RUBY
      end
    end
  end

  context 'when checking all set bits' do
    context 'when Ruby >= 2.5', :ruby25 do
      it 'registers an offense when using `&` with RHS flags in conjunction with `==` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags) == flags
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.allbits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.allbits?(flags)
        RUBY
      end

      it 'registers an offense when using `&` with LHS flags in conjunction with `==` for comparisons' do
        expect_offense(<<~RUBY)
          (flags & variable) == flags
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.allbits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.allbits?(flags)
        RUBY
      end

      it 'does not register an offense when using `allbits?` method' do
        expect_no_offenses(<<~RUBY)
          variable.allbits?(flags)
        RUBY
      end

      it 'does not register an offense when flag variable names are mismatched' do
        expect_no_offenses(<<~RUBY)
          (flags & variable) == flagments
        RUBY
      end
    end

    context 'when Ruby <= 2.4', :ruby24, unsupported_on: :prism do
      it 'does not register an offense when using `&` with RHS flags in conjunction with `==` for comparisons' do
        expect_no_offenses(<<~RUBY)
          (variable & flags) == flags
        RUBY
      end
    end
  end

  context 'when checking no set bits' do
    context 'when Ruby >= 2.5', :ruby25 do
      it 'registers an offense when using `&` in conjunction with `zero?` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags).zero?
          ^^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.nobits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.nobits?(flags)
        RUBY
      end

      it 'registers an offense when using `&` in conjunction with `== 0` for comparisons' do
        expect_offense(<<~RUBY)
          (variable & flags) == 0
          ^^^^^^^^^^^^^^^^^^^^^^^ Replace with `variable.nobits?(flags)` for comparison with bit flags.
        RUBY

        expect_correction(<<~RUBY)
          variable.nobits?(flags)
        RUBY
      end

      it 'does not register an offense when using `nobits?` method' do
        expect_no_offenses(<<~RUBY)
          variable.nobits?(flags)
        RUBY
      end
    end

    context 'when Ruby <= 2.4', :ruby24, unsupported_on: :prism do
      it 'does not register an offense when using `&` in conjunction with `zero?` for comparisons' do
        expect_no_offenses(<<~RUBY)
          (variable & flags).zero?
        RUBY
      end
    end
  end

  context 'when using a simple method call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        zero?
      RUBY
    end
  end
end
