# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyStringInsideInterpolation, :config do
  it 'registers an offense when an empty single-quoted string is the false outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? 'foo' : ''}"
         ^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when an empty double-quoted string is the false outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? 'foo' : ""}"
         ^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when nil is the false outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? 'foo' : nil}"
         ^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when an empty single-quoted string is the false outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; 'foo' else '' end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when an empty double-quoted string is the false outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; 'foo' else "" end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when nil is the false outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; 'foo' else nil end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' if condition}"
    RUBY
  end

  it 'registers an offense when an empty single-quoted string is the true outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? '' : 'foo'}"
         ^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end

  it 'registers an offense when an empty double-quoted string is the true outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? "" : 'foo'}"
         ^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end

  it 'registers an offense when nil is the true outcome of a ternary' do
    expect_offense(<<~'RUBY')
      "#{condition ? nil : 'foo'}"
         ^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end

  it 'registers an offense when an empty single-quoted string is the true outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; '' else 'foo' end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end

  it 'registers an offense when an empty double-quoted string is the true outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; "" else 'foo' end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end

  it 'registers an offense when nil is the true outcome of a single-line conditional' do
    expect_offense(<<~'RUBY')
      "#{if condition; nil else 'foo' end}"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign empty strings to variables inside string interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{'foo' unless condition}"
    RUBY
  end
end
