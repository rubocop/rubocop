# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::HashMissingClass, :config do
  it 'registers an offense and corrects when `hash` delegates to Array#hash without self.class' do
    expect_offense(<<~RUBY)
      def hash
        [a, @b].hash
         ^^^^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class, a, @b].hash
      end
    RUBY
  end

  it 'registers an offense and corrects for empty array hash' do
    expect_offense(<<~RUBY)
      def hash
        [].hash
         ^{} Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class].hash
      end
    RUBY
  end

  it 'registers an offense and corrects when `hash` delegates to Array#hash without self.class with trailing comma' do
    expect_offense(<<~RUBY)
      def hash
        [a, @b,].hash
         ^^^^^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class, a, @b,].hash
      end
    RUBY
  end

  it 'registers an offense and corrects when `hash` delegates to Array#hash including `other.class`' do
    expect_offense(<<~RUBY)
      def hash
        [other.class, a, @b].hash
         ^^^^^^^^^^^^^^^^^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class, other.class, a, @b].hash
      end
    RUBY
  end

  it 'registers an offense even when composing intermediate values' do
    expect_offense(<<~RUBY)
      def hash
        complex_b = calculate_b

        [a, complex_b].hash
         ^^^^^^^^^^^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        complex_b = calculate_b

        [self.class, a, complex_b].hash
      end
    RUBY
  end

  it 'does not register an offense when `hash` includes self.class (regardless of order)' do
    expect_no_offenses(<<~RUBY)
      def hash
        [self.class, a, @b].hash
      end

      def hash
        [a, self.class, @b].hash
      end

      def hash
        [a, @b, self.class].hash
      end
    RUBY
  end

  it 'does not register an offense for different hash implementations' do
    # These are covered by `Security/CompoundHash`
    expect_no_offenses(<<~RUBY)
      def hash
        a.hash ^ @b.hash
      end

      def hash
      end

      def hash
        nil
      end

      def hash
        []
      end

      def hash
        a.hash
      end

      def hash
        @b.hash
      end

      def hash
        super ^ a.hash
      end

      def hash
        super
      end
    RUBY
  end

  it 'does not register an offense for hash methods with arguments' do
    expect_no_offenses(<<~RUBY)
      def hash(other)
        [a, @b, other].hash
      end
    RUBY
  end

  it 'does not register an offense when super is in array, regardless of order' do
    expect_no_offenses(<<~RUBY)
      def hash
        [a, @b, super]
      end

      def hash
        [a, super, @b]
      end

      def hash
        [super, a, @b]
      end
    RUBY
  end

  it 'does not register an offense for `Array#hash` usage in non-`hash` methods' do
    expect_no_offenses(<<~RUBY)
      def other_method
        [a, @b].hash
      end
    RUBY
  end

  it 'registers an offense for complex array elements without self.class' do
    expect_offense(<<~RUBY)
      def hash
        [CONSTANT, foo(), @bar].hash
         ^^^^^^^^^^^^^^^^^^^^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class, CONSTANT, foo(), @bar].hash
      end
    RUBY
  end

  it 'registers an offense for multiline array without self.class' do
    expect_offense(<<~RUBY)
      def hash
        [
         ^{} Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
          a,
          @b
        ].hash
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [
          self.class,
          a,
          @b
        ].hash
      end
    RUBY
  end

  it 'registers an offense for multiline array without self.class with first element on the same line' do
    expect_offense(<<~RUBY)
      def hash
        [a,
         ^^ Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
          @b
        ].hash
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [self.class,
          a,
          @b
        ].hash
      end
    RUBY
  end

  it 'registers an offense for empty multiline array' do
    expect_offense(<<~RUBY)
      def hash
        [
         ^{} Include 'self.class' in 'hash' to ensure instances of different classes have distinct hash values.
        ].hash
      end
    RUBY

    expect_correction(<<~RUBY)
      def hash
        [
          self.class,
        ].hash
      end
    RUBY
  end
end
