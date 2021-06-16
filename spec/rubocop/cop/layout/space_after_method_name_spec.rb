# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterMethodName, :config do
  it 'registers an offense and corrects def with space before the parenthesis' do
    expect_offense(<<~RUBY)
      def func (x)
              ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY

    expect_correction(<<~RUBY)
      def func(x)
        a
      end
    RUBY
  end

  it 'registers offense and corrects class def with space before parenthesis' do
    expect_offense(<<~RUBY)
      def self.func (x)
                   ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.func(x)
        a
      end
    RUBY
  end

  it 'registers offense and corrects assignment def with space before parenthesis' do
    expect_offense(<<~RUBY)
      def func= (x)
               ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY

    expect_correction(<<~RUBY)
      def func=(x)
        a
      end
    RUBY
  end

  it 'accepts a def without arguments' do
    expect_no_offenses(<<~RUBY)
      def func
        a
      end
    RUBY
  end

  it 'accepts a defs without arguments' do
    expect_no_offenses(<<~RUBY)
      def self.func
        a
      end
    RUBY
  end

  it 'accepts a def with arguments but no parentheses' do
    expect_no_offenses(<<~RUBY)
      def func x
        a
      end
    RUBY
  end

  it 'accepts class method def with arguments but no parentheses' do
    expect_no_offenses(<<~RUBY)
      def self.func x
        a
      end
    RUBY
  end

  it 'accepts an assignment def with arguments but no parentheses' do
    expect_no_offenses(<<~RUBY)
      def func= x
        a
      end
    RUBY
  end
end
