# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterColon, :config do
  it 'registers an offense and corrects colon without space after it' do
    expect_offense(<<~RUBY)
      {a:3}
        ^ Space missing after colon.
    RUBY

    expect_correction(<<~RUBY)
      {a: 3}
    RUBY
  end

  it 'accepts colons in symbols' do
    expect_no_offenses('x = :a')
  end

  it 'accepts colon in ternary followed by space' do
    expect_no_offenses('x = w ? a : b')
  end

  it 'accepts hashes with a space after colons' do
    expect_no_offenses('{a: 3}')
  end

  it 'accepts hash rockets' do
    expect_no_offenses('x = {"a"=>1}')
  end

  it 'accepts if' do
    expect_no_offenses(<<~RUBY)
      x = if w
            a
          end
    RUBY
  end

  it 'accepts colons in strings' do
    expect_no_offenses("str << ':'")
  end

  it 'accepts required keyword arguments' do
    expect_no_offenses(<<~RUBY)
      def f(x:, y:)
      end
    RUBY
  end

  it 'accepts colons denoting required keyword argument' do
    expect_no_offenses(<<~RUBY)
      def initialize(table:, nodes:)
      end
    RUBY
  end

  it 'registers an offense and corrects a keyword optional argument without a space' do
    expect_offense(<<~RUBY)
      def m(var:1, other_var: 2)
               ^ Space missing after colon.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(var: 1, other_var: 2)
      end
    RUBY
  end

  context 'Ruby >= 3.1', :ruby31 do
    it 'does not register an offense colon without space after it when using hash value omission' do
      expect_no_offenses('{x:, y:}')
    end

    it 'accepts colons denoting hash value omission argument' do
      expect_no_offenses(<<~RUBY)
        foo(table:, nodes:)
      RUBY
    end
  end
end
