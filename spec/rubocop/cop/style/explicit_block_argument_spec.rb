# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ExplicitBlockArgument, :config do
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

  it 'registers an offense and corrects when multiple arguments are yielded' do
    expect_offense(<<~RUBY)
      def m
        items.something(first_arg) { |i, j| yield i, j }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(first_arg, &block)
      end
    RUBY
  end

  it 'does not register an offense when arguments are yielded in a different order' do
    expect_no_offenses(<<~RUBY)
      def m
        items.something(first_arg) { |i, j| yield j, i }
      end
    RUBY
  end

  it 'correctly corrects when method already has an explicit block argument' do
    expect_offense(<<~RUBY)
      def m(&blk)
        items.something { |i| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&blk)
        items.something(&blk)
      end
    RUBY
  end

  it 'correctly corrects when the method call has a trailing comma in its argument list' do
    expect_offense(<<~RUBY)
      def m
        items.something(a, b,) { |i| yield i }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(a, b, &block)
      end
    RUBY
  end

  it 'correctly corrects when using safe navigation method call' do
    expect_offense(<<~RUBY)
      def do_something
        array&.each do |row|
        ^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
          yield row
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_something(&block)
        array&.each(&block)
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
          ^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
        else
          other_items.something { |i, j| yield i, j }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        items.something(&block)

        if condition
          yield 2
        elsif other_condition
          3.times(&block)
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

  it 'registers an offense and corrects when `yield` inside block has no arguments' do
    expect_offense(<<~RUBY)
      def m
        3.times { yield }
        ^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m(&block)
        3.times(&block)
      end
    RUBY
  end

  it 'registers an offense and corrects when `yield` is inside block of `super`' do
    expect_offense(<<~RUBY)
      def do_something
        super { yield }
        ^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_something(&block)
        super(&block)
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

  it 'does not register an offense when there is more than one block argument and not all are yielded' do
    expect_no_offenses(<<~RUBY)
      def m
        items.something { |i, j| yield i }
      end
    RUBY
  end

  it 'does not register an offense when code is called outside of a method' do
    expect_no_offenses(<<~RUBY)
      render("partial") do
        yield
      end
    RUBY
  end

  it 'does not add extra parens when correcting' do
    expect_offense(<<~RUBY)
      def my_method()
        foo() { yield }
        ^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY, loop: false)
      def my_method(&block)
        foo(&block)
      end
    RUBY
  end

  it 'does not add extra parens to `super` when correcting' do
    expect_offense(<<~RUBY)
      def my_method
        super() { yield }
        ^^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY, loop: false)
      def my_method(&block)
        super(&block)
      end
    RUBY
  end

  it 'adds to the existing arguments when correcting' do
    expect_offense(<<~RUBY)
      def my_method(x)
        foo(x) { yield }
        ^^^^^^^^^^^^^^^^ Consider using explicit block argument in the surrounding method's signature over `yield`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def my_method(x, &block)
        foo(x, &block)
      end
    RUBY
  end
end
