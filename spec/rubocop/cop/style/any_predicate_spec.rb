# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AnyPredicate, :config do
  it 'registers an offense with `array.any?`' do
    expect_offense(<<~RUBY)
      [foo, bar, baz].any?
      ^^^^^^^^^^^^^^^^^^^^ Prefer an OR expression instead.
    RUBY

    expect_correction(<<~RUBY)
      (foo || bar || baz)
    RUBY
  end

  it 'registers an offense with multiline `array.any?`' do
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

  it 'registers an offense with `!array.any?`' do
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

  it 'does not register an offense with methods other than `any?`' do
    expect_no_offenses(<<~RUBY)
      [foo, bar, baz].quux?
    RUBY
  end
end
