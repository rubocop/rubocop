# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingCommaInBlockArgs, :config do
  context 'curly brace block format' do
    it 'registers an offense when a trailing comma is not needed' do
      expect_offense(<<~RUBY)
        test { |a, b,| a + b }
                    ^ Useless trailing comma present in block arguments.
      RUBY

      expect_correction(<<~RUBY)
        test { |a, b| a + b }
      RUBY
    end

    it 'does not register an offense when a trailing comma is required' do
      expect_no_offenses(<<~RUBY)
        test { |a,| a }
      RUBY
    end

    it 'does not register an offense when no arguments are present' do
      expect_no_offenses(<<~RUBY)
        test { a }
      RUBY
    end

    it 'does not register an offense when more than one argument is ' \
       'present with no trailing comma' do
      expect_no_offenses(<<~RUBY)
        test { |a, b| a + b }
      RUBY
    end

    it 'does not register an offense for default arguments' do
      expect_no_offenses(<<~RUBY)
        test { |a, b, c = nil| a + b + c }
      RUBY
    end

    it 'does not register an offense for keyword arguments' do
      expect_no_offenses(<<~RUBY)
        test { |a, b, c: 1| a + b + c }
      RUBY
    end

    it 'ignores commas in default argument strings' do
      expect_no_offenses(<<~RUBY)
        add { |foo, bar = ','| foo + bar }
      RUBY
    end

    it 'preserves semicolons in block/local variables' do
      expect_no_offenses(<<~RUBY)
        add { |foo, bar,; baz| foo + bar }
      RUBY
    end
  end

  context 'do/end block format' do
    it 'registers an offense when a trailing comma is not needed' do
      expect_offense(<<~RUBY)
        test do |a, b,|
                     ^ Useless trailing comma present in block arguments.
          a + b
        end
      RUBY

      expect_correction(<<~RUBY)
        test do |a, b|
          a + b
        end
      RUBY
    end

    it 'does not register an offense when a trailing comma is required' do
      expect_no_offenses(<<~RUBY)
        test do |a,|
          a
        end
      RUBY
    end

    it 'does not register an offense when no arguments are present' do
      expect_no_offenses(<<~RUBY)
        test do
          a
        end
      RUBY
    end

    it 'does not register an offense for an empty block' do
      expect_no_offenses(<<~RUBY)
        test do ||
        end
      RUBY
    end

    it 'does not register an offense when more than one argument is ' \
       'present with no trailing comma' do
      expect_no_offenses(<<~RUBY)
        test do |a, b|
          a + b
        end
      RUBY
    end

    it 'does not register an offense for default arguments' do
      expect_no_offenses(<<~RUBY)
        test do |a, b, c = nil|
           a + b + c
        end
      RUBY
    end

    it 'does not register an offense for keyword arguments' do
      expect_no_offenses(<<~RUBY)
        test do |a, b, c: 1|
           a + b + c
        end
      RUBY
    end

    it 'ignores commas in default argument strings' do
      expect_no_offenses(<<~RUBY)
        add do |foo, bar = ','|
          foo + bar
        end
      RUBY
    end

    it 'preserves semicolons in block/local variables' do
      expect_no_offenses(<<~RUBY)
        add do |foo, bar,; baz|
          foo + bar
        end
      RUBY
    end
  end

  context 'when `->` has multiple arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        -> (foo, bar) { do_something(foo, bar) }
      RUBY
    end
  end

  context 'when `lambda` has multiple arguments' do
    it 'does not register an offense when more than one argument is ' \
       'present with no trailing comma' do
      expect_no_offenses(<<~RUBY)
        lambda { |foo, bar| do_something(foo, bar) }
      RUBY
    end

    it "registers an offense and corrects when a trailing comma isn't needed" do
      expect_offense(<<~RUBY)
        lambda { |foo, bar,| do_something(foo, bar) }
                          ^ Useless trailing comma present in block arguments.
      RUBY

      expect_correction(<<~RUBY)
        lambda { |foo, bar| do_something(foo, bar) }
      RUBY
    end
  end
end
