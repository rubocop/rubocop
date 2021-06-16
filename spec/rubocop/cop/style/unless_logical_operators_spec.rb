# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnlessLogicalOperators, :config do
  context 'EnforcedStyle is `forbid_mixed_logical_operators`' do
    let(:cop_config) { { 'EnforcedStyle' => 'forbid_mixed_logical_operators' } }

    it 'registers an offense when using `&&` and `||`' do
      expect_offense(<<~RUBY)
        return unless a && b || c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY

      expect_offense(<<~RUBY)
        return unless a || b && c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'registers an offense when using `&&` and `and`' do
      expect_offense(<<~RUBY)
        return unless a && b and c
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY

      expect_offense(<<~RUBY)
        return unless a and b && c
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'registers an offense when using `&&` and `or`' do
      expect_offense(<<~RUBY)
        return unless a && b or c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY

      expect_offense(<<~RUBY)
        return unless a or b && c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'registers an offense when using `||` and `or`' do
      expect_offense(<<~RUBY)
        return unless a || b or c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY

      expect_offense(<<~RUBY)
        return unless a or b || c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'registers an offense when using `||` and `and`' do
      expect_offense(<<~RUBY)
        return unless a || b and c
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY

      expect_offense(<<~RUBY)
        return unless a and b || c
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'registers an offense when using parentheses' do
      expect_offense(<<~RUBY)
        return unless a || (b && c) || d
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use mixed logical operators in an `unless`.
      RUBY
    end

    it 'does not register an offense when using only `&&`s' do
      expect_no_offenses(<<~RUBY)
        return unless a && b && c
      RUBY
    end

    it 'does not register an offense when using only `||`s' do
      expect_no_offenses(<<~RUBY)
        return unless a || b || c
      RUBY
    end

    it 'does not register an offense when using only `and`s' do
      expect_no_offenses(<<~RUBY)
        return unless a and b and c
      RUBY
    end

    it 'does not register an offense when using only `or`s' do
      expect_no_offenses(<<~RUBY)
        return unless a or b or c
      RUBY
    end

    it 'does not register an offense when using if' do
      expect_no_offenses(<<~RUBY)
        return if a || b && c || d
      RUBY
    end

    it 'does not register an offense when not used in unless' do
      expect_no_offenses(<<~RUBY)
        def condition?
          a or b && c || d
        end
      RUBY
    end

    it 'does not register an offense when not using logical operator' do
      expect_no_offenses(<<~RUBY)
        return unless a?
      RUBY
    end

    it 'does not register an offense when using `||` operator and invoked method name includes "or" in the conditional branch' do
      expect_no_offenses(<<~RUBY)
        unless condition
          includes_or_in_the_name

          foo || bar
        end
      RUBY
    end

    it 'does not register an offense when using `&&` operator and invoked method name includes "and" in the conditional branch' do
      expect_no_offenses(<<~RUBY)
        unless condition
          includes_and_in_the_name

          foo && bar
        end
      RUBY
    end
  end

  context 'EnforcedStyle is `forbid_logical_operators`' do
    let(:cop_config) { { 'EnforcedStyle' => 'forbid_logical_operators' } }

    it 'registers an offense when using only `&&`' do
      expect_offense(<<~RUBY)
        return unless a && b
        ^^^^^^^^^^^^^^^^^^^^ Do not use any logical operator in an `unless`.
      RUBY
    end

    it 'registers an offense when using only `||`' do
      expect_offense(<<~RUBY)
        return unless a || b
        ^^^^^^^^^^^^^^^^^^^^ Do not use any logical operator in an `unless`.
      RUBY
    end

    it 'registers an offense when using only `and`' do
      expect_offense(<<~RUBY)
        return unless a and b
        ^^^^^^^^^^^^^^^^^^^^^ Do not use any logical operator in an `unless`.
      RUBY
    end

    it 'registers an offense when using only `or`' do
      expect_offense(<<~RUBY)
        return unless a or b
        ^^^^^^^^^^^^^^^^^^^^ Do not use any logical operator in an `unless`.
      RUBY
    end

    it 'registers an offense when using `&&` followed by ||' do
      expect_offense(<<~RUBY)
        return unless a && b || c
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use any logical operator in an `unless`.
      RUBY
    end

    it 'does not register an offense when using if' do
      expect_no_offenses(<<~RUBY)
        return if a || b
      RUBY
    end

    it 'does not register an offense when not used in unless' do
      expect_no_offenses(<<~RUBY)
        def condition?
          a || b
        end
      RUBY
    end

    it 'does not register an offense when not using logical operator' do
      expect_no_offenses(<<~RUBY)
        return unless a?
      RUBY
    end
  end
end
