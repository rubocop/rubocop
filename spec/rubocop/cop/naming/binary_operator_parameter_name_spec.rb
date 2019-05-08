# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::BinaryOperatorParameterName do
  subject(:cop) { described_class.new }

  it 'registers an offense for `#+` when argument is not named other' do
    expect_offense(<<~RUBY)
      def +(foo); end
            ^^^ When defining the `+` operator, name its argument `other`.
    RUBY
  end

  it 'registers an offense for `#eql?` when argument is not named other' do
    expect_offense(<<~RUBY)
      def eql?(foo); end
               ^^^ When defining the `eql?` operator, name its argument `other`.
    RUBY
  end

  it 'registers an offense for `#equal?` when argument is not named other' do
    expect_offense(<<~RUBY)
      def equal?(foo); end
                 ^^^ When defining the `equal?` operator, name its argument `other`.
    RUBY
  end

  it 'works properly even if the argument not surrounded with braces' do
    expect_offense(<<~RUBY)
      def + another
            ^^^^^^^ When defining the `+` operator, name its argument `other`.
        another
      end
    RUBY
  end

  it 'does not register an offense for arg named other' do
    expect_no_offenses(<<~RUBY)
      def +(other)
        other
      end
    RUBY
  end

  it 'does not register an offense for arg named _other' do
    expect_no_offenses(<<~RUBY)
      def <=>(_other)
        0
      end
    RUBY
  end

  it 'does not register an offense for []' do
    expect_no_offenses(<<~RUBY)
      def [](index)
        other
      end
    RUBY
  end

  it 'does not register an offense for []=' do
    expect_no_offenses(<<~RUBY)
      def []=(index, value)
        other
      end
    RUBY
  end

  it 'does not register an offense for <<' do
    expect_no_offenses(<<~RUBY)
      def <<(cop)
        other
      end
    RUBY
  end

  it 'does not register an offense for ===' do
    expect_no_offenses(<<~RUBY)
      def ===(string)
        string
      end
    RUBY
  end

  it 'does not register an offense for non binary operators' do
    expect_no_offenses(<<~RUBY)
      def -@; end
                    # This + is not a unary operator. It can only be
                    # called with dot notation.
      def +; end
      def *(a, b); end # Quite strange, but legal ruby.
      def `(cmd); end
    RUBY
  end
end
