# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TimeNow, :config do
  it 'registers an offense when using `Time.new` without arguments' do
    expect_offense(<<~RUBY)
      Time.new
      ^^^^^^^^ Prefer `Time.now` over `Time.new` to retrieve the current time.
    RUBY

    expect_correction(<<~RUBY)
      Time.now
    RUBY
  end

  it 'registers an offense when using `Time.new` with parentheses and no arguments' do
    expect_offense(<<~RUBY)
      Time.new()
      ^^^^^^^^^^ Prefer `Time.now` over `Time.new` to retrieve the current time.
    RUBY

    expect_correction(<<~RUBY)
      Time.now
    RUBY
  end

  it 'registers an offense when using `::Time.new`' do
    expect_offense(<<~RUBY)
      ::Time.new
      ^^^^^^^^^^ Prefer `Time.now` over `Time.new` to retrieve the current time.
    RUBY

    expect_correction(<<~RUBY)
      ::Time.now
    RUBY
  end

  it 'registers an offense when using `Time&.new`' do
    expect_offense(<<~RUBY)
      Time&.new
      ^^^^^^^^^ Prefer `Time.now` over `Time.new` to retrieve the current time.
    RUBY

    expect_correction(<<~RUBY)
      Time&.now
    RUBY
  end

  it 'registers an offense when `Time.new` is a receiver' do
    expect_offense(<<~RUBY)
      Time.new.year
      ^^^^^^^^ Prefer `Time.now` over `Time.new` to retrieve the current time.
    RUBY

    expect_correction(<<~RUBY)
      Time.now.year
    RUBY
  end

  it 'does not register an offense when using `Time.now`' do
    expect_no_offenses(<<~RUBY)
      Time.now
    RUBY
  end

  it 'does not register an offense when using `Time.new` with arguments' do
    expect_no_offenses(<<~RUBY)
      Time.new(2026, 8, 19)
    RUBY
  end

  it 'does not register an offense when using `Time.new` with a keyword argument' do
    expect_no_offenses(<<~RUBY)
      Time.new(in: '+09:00')
    RUBY
  end

  it 'does not register an offense when calling `new` on a namespaced `Time` constant' do
    expect_no_offenses(<<~RUBY)
      Foo::Time.new
    RUBY
  end

  it 'does not register an offense when calling `new` on another constant' do
    expect_no_offenses(<<~RUBY)
      Date.new
    RUBY
  end

  it 'does not register an offense when calling `new` without a receiver' do
    expect_no_offenses(<<~RUBY)
      new
    RUBY
  end
end
