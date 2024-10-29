# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CombinableDefined, :config do
  it 'does not register an offense for a single `defined?`' do
    expect_no_offenses(<<~RUBY)
      defined?(Foo)
    RUBY
  end

  %i[&& and].each do |operator|
    context "joined by `#{operator}`" do
      it 'does not register an offense for two separate `defined?`s' do
        expect_no_offenses(<<~RUBY)
          defined?(Foo) #{operator} defined?(Bar)
        RUBY
      end

      it 'does not register an offense for two identical `defined?`s' do
        # handled by Lint/BinaryOperatorWithIdenticalOperands
        expect_no_offenses(<<~RUBY)
          defined?(Foo) #{operator} defined?(Foo)
        RUBY
      end

      it 'does not register an offense for the same constant with different `cbase`s' do
        expect_no_offenses(<<~RUBY)
          defined?(Foo) #{operator} defined?(::Foo)
        RUBY
      end

      it 'registers an offense for two `defined?`s with same nesting' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(Foo) #{operator} defined?(Foo::Bar)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(Foo::Bar)
        RUBY
      end

      it 'registers an offense for two `defined?`s with the same nesting in reverse order' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(Foo::Bar) #{operator} defined?(Foo)
          ^^^^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(Foo::Bar)
        RUBY
      end

      it 'registers an offense for two `defined?`s with the same nesting and `cbase`' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(::Foo) #{operator} defined?(::Foo::Bar)
          ^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(::Foo::Bar)
        RUBY
      end

      it 'registers an offense for two `defined?`s with the same deep nesting' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(Foo::Bar) #{operator} defined?(Foo::Bar::Baz)
          ^^^^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(Foo::Bar::Baz)
        RUBY
      end

      it 'registers an offense for three `defined?`s with same nesting' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(Foo) #{operator} defined?(Foo::Bar) #{operator} defined?(Foo::Bar::Baz)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(Foo::Bar::Baz)
        RUBY
      end

      it 'registers an offense for three `defined?`s with the same module ancestor' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(Foo) #{operator} defined?(Foo::Bar) #{operator} defined?(Foo::Baz)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(Foo::Bar) #{operator} defined?(Foo::Baz)
        RUBY
      end

      it 'does not register an offense for two `defined?`s with same namespace but different nesting' do
        expect_no_offenses(<<~RUBY)
          defined?(Foo::Bar) #{operator} defined?(Foo::Baz)
        RUBY
      end

      it 'does not register an offense for two `defined?`s with negation' do
        expect_no_offenses(<<~RUBY)
          defined?(Foo) #{operator} !defined?(Foo::Bar)
        RUBY
      end

      it 'does not register an offense for two `defined?` with different `cbase`s' do
        expect_no_offenses(<<~RUBY)
          defined?(::Foo) #{operator} defined?(Foo::Bar)
        RUBY
      end

      it 'does not register an offense when skipping a nesting level' do
        expect_no_offenses(<<~RUBY)
          defined?(Foo) #{operator} defined?(Foo::Bar::Baz)
        RUBY
      end

      it 'registers an offense when the namespace is not a constant' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(foo) #{operator} defined?(foo::Bar)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(foo::Bar)
        RUBY
      end

      it 'registers an offense for method chain with dots' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(foo) #{operator} defined?(foo.bar)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(foo.bar)
        RUBY
      end

      it 'registers an offense for method chain with `::`' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(foo) #{operator} defined?(foo::bar)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(foo::bar)
        RUBY
      end

      it 'registers an offense for a method chain followed by constant nesting' do
        expect_offense(<<~RUBY, operator: operator)
          defined?(foo) #{operator} defined?(foo.bar) #{operator} defined?(foo.bar::BAZ)
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
          ^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^{operator}^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        RUBY

        expect_correction(<<~RUBY)
          defined?(foo.bar::BAZ)
        RUBY
      end

      it 'does not register an offense when there is another term between `defined?`s' do
        expect_no_offenses(<<~RUBY)
          foo #{operator} defined?(Foo) #{operator} bar #{operator} defined?(Foo::Bar)
        RUBY
      end
    end
  end

  context 'mixed operators' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        defined?(Foo) && defined?(Foo::Bar) and defined?(Foo::Bar::Baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
      RUBY

      expect_correction(<<~RUBY)
        defined?(Foo::Bar::Baz)
      RUBY
    end

    it 'registers an offense and corrects when an operator is retained' do
      expect_offense(<<~RUBY)
        defined?(Foo) && defined?(Foo::Bar) and defined?(Foo::Baz)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine nested `defined?` calls.
      RUBY

      # The deleted operator is the one attached to the term being removed
      # (in this case `defined?(Foo)`).
      # `Style/AndOr` will subsequently update the operator if necessary.
      expect_correction(<<~RUBY)
        defined?(Foo::Bar) and defined?(Foo::Baz)
      RUBY
    end
  end
end
