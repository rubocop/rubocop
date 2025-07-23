# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayLiteralAsLogicalExpression, :config do
  context 'with method `any?`' do
    it 'registers an offense for `array.any?`' do
      expect_offense(<<~RUBY)
        [foo, bar, baz].any?
        ^^^^^^^^^^^^^^^^^^^^ Prefer an OR expression instead.
      RUBY

      expect_correction(<<~RUBY)
        (foo || bar || baz)
      RUBY
    end

    it 'registers an offense for multiline `array.any?`' do
      expect_offense(<<~RUBY)
        [foo,
        ^^^^^ Prefer an OR expression instead.
        bar,
        baz].any?
      RUBY

      expect_correction(<<~RUBY)
        (foo || bar || baz)
      RUBY
    end

    it 'registers an offense for `!array.any?`' do
      expect_offense(<<~RUBY)
        ![foo, bar, baz].any?
         ^^^^^^^^^^^^^^^^^^^^ Prefer an OR expression instead.
      RUBY

      expect_correction(<<~RUBY)
        !(foo || bar || baz)
      RUBY
    end

    it 'does not register an offense for splat array item' do
      expect_no_offenses(<<~RUBY)
        [*foo].any?
      RUBY
    end

    it 'does not register an offense for empty array' do
      expect_no_offenses(<<~RUBY)
        [].any?
      RUBY
    end

    it 'does not register an offense when `any?` has an argument' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].any?(arg)
      RUBY
    end

    it 'does not register an offense when `any?` has a block pass argument' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].any?(&:block)
      RUBY
    end

    it 'does not register an offense when `any?` has a block' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].any? { |item| bla }
      RUBY
    end

    it 'does not register an offense when `any?` has a numblock' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].any? { _1 }
      RUBY
    end

    it 'does not register an offense when `any?` has an itblock' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].any? { it }
      RUBY
    end

    context 'when `MaxCheckedSize: 3` (default)' do
      it 'does not register an offense for `array.any?` with 4 elements' do
        expect_no_offenses(<<~RUBY)
          [foo, bar, baz, quux].any?
        RUBY
      end
    end

    context 'when `MaxCheckedSize: 4`' do
      let(:cop_config) { { 'MaxCheckedSize' => 4 } }

      it 'registers an offense for `array.any?` with 4 elements' do
        expect_offense(<<~RUBY)
          [foo, bar, baz, quux].any?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer an OR expression instead.
        RUBY

        expect_correction(<<~RUBY)
          (foo || bar || baz || quux)
        RUBY
      end
    end
  end

  context 'with method `all?`' do
    it 'registers an offense for `array.all?`' do
      expect_offense(<<~RUBY)
        [foo, bar, baz].all?
        ^^^^^^^^^^^^^^^^^^^^ Prefer an AND expression instead.
      RUBY

      expect_correction(<<~RUBY)
        (foo && bar && baz)
      RUBY
    end

    it 'registers an offense for multiline `array.all??`' do
      expect_offense(<<~RUBY)
        [foo,
        ^^^^^ Prefer an AND expression instead.
        bar,
        baz].all?
      RUBY

      expect_correction(<<~RUBY)
        (foo && bar && baz)
      RUBY
    end

    it 'registers an offense for `!array.all?`' do
      expect_offense(<<~RUBY)
        ![foo, bar, baz].all?
         ^^^^^^^^^^^^^^^^^^^^ Prefer an AND expression instead.
      RUBY

      expect_correction(<<~RUBY)
        !(foo && bar && baz)
      RUBY
    end

    it 'does not register an offense for splat array item' do
      expect_no_offenses(<<~RUBY)
        [*foo].all?
      RUBY
    end

    it 'does not register an offense for empty array' do
      expect_no_offenses(<<~RUBY)
        [].all?
      RUBY
    end

    it 'does not register an offense when `all?` has an argument' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].all?(arg)
      RUBY
    end

    it 'does not register an offense when `all?` has a block pass argument' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].all?(&:block)
      RUBY
    end

    it 'does not register an offense when `all?` has a block' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].all? { |item| bla }
      RUBY
    end

    it 'does not register an offense when `all?` has a numblock' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].all? { _1 }
      RUBY
    end

    it 'does not register an offense when `all?` has an itblock' do
      expect_no_offenses(<<~RUBY)
        [foo, bar, baz].all? { it }
      RUBY
    end

    context 'when `MaxCheckedSize: 3` (default)' do
      it 'does not register an offense for `array.all?` with 4 elements' do
        expect_no_offenses(<<~RUBY)
          [foo, bar, baz, quux].all?
        RUBY
      end
    end

    context 'when `MaxCheckedSize: 4`' do
      let(:cop_config) { { 'MaxCheckedSize' => 4 } }

      it 'registers an offense for `array.any?` with 4 elements' do
        expect_offense(<<~RUBY)
          [foo, bar, baz, quux].all?
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer an AND expression instead.
        RUBY

        expect_correction(<<~RUBY)
          (foo && bar && baz && quux)
        RUBY
      end
    end
  end

  it 'does not register an offense for methods other than `any?` or `all?`' do
    expect_no_offenses(<<~RUBY)
      [foo, bar, baz].quux?
    RUBY
  end
end
