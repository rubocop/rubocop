# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ExplicitBlockArgument do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when block just yields its arguments' do
    expect_offense(<<~RUBY)
      def m
        items.something(first_arg) { |i| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(first_arg, &block)
      end
    RUBY
  end

  it 'registers an offense and corrects when block yields several first its arguments' do
    expect_offense(<<~RUBY)
      def m
        items.something { |i, j| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(&block)
      end
    RUBY
  end

  it 'correctly corrects when method already has an explicit block argument' do
    expect_offense(<<~RUBY)
      def m(&block)
        items.something { |i| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(&block)
      end
    RUBY
  end

  it 'registers an offense and corrects when method contains multiple `yield`s' do
    expect_offense(<<~RUBY)
      def m
        items.something { |i| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.

        if condition
          yield 2
        elsif other_condition
          3.times { yield }
        else
          other_items.something { |i, j| yield i }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(&block)

        if condition
          yield 2
        elsif other_condition
          3.times { yield }
        else
          other_items.something(&block)
        end
      end
    RUBY
  end

  it 'does not register an offense when `yield` is not inside block' do
    expect_no_offenses(<<~RUBY)
      def m
        yield i
      end
    RUBY
  end

  it 'does not register an offense when `yield` inside block has no arguments' do
    expect_no_offenses(<<~RUBY)
      def m
        3.times { yield }
      end
    RUBY
  end

  it 'does not register an offense when `yield` is the sole block body' do
    expect_no_offenses(<<~RUBY)
      def m
        items.something do |i|
          do_something
          yield i
        end
      end
    RUBY
  end

  it 'does not register an offense when `yield` arguments is not a prefix of block arguments' do
    expect_no_offenses(<<~RUBY)
      def m
        items.something { |i, j, k| yield j, k }
      end
    RUBY
  end
end
