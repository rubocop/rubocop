# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Eql, :config do
  it 'registers an offense and corrects when using `eql?` with a parenthesized argument' do
    expect_offense(<<~RUBY)
      'ruby'.eql?(some_str)
      ^^^^^^^^^^^^^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      'ruby' == some_str
    RUBY
  end

  it 'registers an offense and corrects when using `eql?` without argument parentheses' do
    expect_offense(<<~RUBY)
      'ruby'.eql? some_str
      ^^^^^^^^^^^^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      'ruby' == some_str
    RUBY
  end

  it 'registers an offense and corrects with parentheses when `eql?` is a receiver of another call' do
    expect_offense(<<~RUBY)
      a.eql?(b).to_s
      ^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      (a == b).to_s
    RUBY
  end

  it 'registers an offense and corrects with parentheses when `eql?` is negated' do
    expect_offense(<<~RUBY)
      !a.eql?(b)
       ^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      !(a == b)
    RUBY
  end

  it 'registers an offense and corrects with parentheses when `eql?` is an operand of an operator' do
    expect_offense(<<~RUBY)
      c == a.eql?(b)
           ^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      c == (a == b)
    RUBY
  end

  it 'registers an offense and corrects without parentheses inside a condition' do
    expect_offense(<<~RUBY)
      if a.eql?(b) && c
         ^^^^^^^^^ Use `==` instead of `eql?`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if a == b && c
      end
    RUBY
  end

  it 'registers an offense and corrects when the receiver is a method chain' do
    expect_offense(<<~RUBY)
      foo.bar.eql?(baz)
      ^^^^^^^^^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar == baz
    RUBY
  end

  it 'registers an offense but does not correct when using safe navigation' do
    expect_offense(<<~RUBY)
      a&.eql?(b)
      ^^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_no_corrections
  end

  it 'registers an offense but does not correct when the argument is a splat' do
    expect_offense(<<~RUBY)
      a.eql?(*b)
      ^^^^^^^^^^ Use `==` instead of `eql?`.
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense when using `==`' do
    expect_no_offenses(<<~RUBY)
      'ruby' == some_str
    RUBY
  end

  it 'does not register an offense when `eql?` has no receiver' do
    expect_no_offenses(<<~RUBY)
      eql?(other)
    RUBY
  end

  it 'does not register an offense when `eql?` has no arguments' do
    expect_no_offenses(<<~RUBY)
      a.eql?
    RUBY
  end

  it 'does not register an offense when `eql?` has multiple arguments' do
    expect_no_offenses(<<~RUBY)
      a.eql?(b, c)
    RUBY
  end

  it 'does not register an offense when `eql?` is called inside a definition of `eql?`' do
    expect_no_offenses(<<~RUBY)
      def eql?(other)
        id.eql?(other.id)
      end
    RUBY
  end

  it 'does not register an offense when using `&:eql?`' do
    expect_no_offenses(<<~RUBY)
      a.any?(&:eql?)
    RUBY
  end

  it 'does not register an offense when using `method(:eql?)`' do
    expect_no_offenses(<<~RUBY)
      a.method(:eql?)
    RUBY
  end
end
