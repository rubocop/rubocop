# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EvenOdd, :config do
  it 'converts x % 2 == 0 to #even?' do
    expect_offense(<<~RUBY)
      x % 2 == 0
      ^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x.even?
    RUBY
  end

  it 'converts x % 2 != 0 to #odd?' do
    expect_offense(<<~RUBY)
      x % 2 != 0
      ^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY

    expect_correction(<<~RUBY)
      x.odd?
    RUBY
  end

  it 'converts (x % 2) == 0 to #even?' do
    expect_offense(<<~RUBY)
      (x % 2) == 0
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x.even?
    RUBY
  end

  it 'converts (x % 2) != 0 to #odd?' do
    expect_offense(<<~RUBY)
      (x % 2) != 0
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY

    expect_correction(<<~RUBY)
      x.odd?
    RUBY
  end

  it 'converts x % 2 == 1 to #odd?' do
    expect_offense(<<~RUBY)
      x % 2 == 1
      ^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY

    expect_correction(<<~RUBY)
      x.odd?
    RUBY
  end

  it 'converts x % 2 != 1 to #even?' do
    expect_offense(<<~RUBY)
      x % 2 != 1
      ^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x.even?
    RUBY
  end

  it 'converts (x % 2) == 1 to #odd?' do
    expect_offense(<<~RUBY)
      (x % 2) == 1
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY

    expect_correction(<<~RUBY)
      x.odd?
    RUBY
  end

  it 'converts (y % 2) != 1 to #even?' do
    expect_offense(<<~RUBY)
      (y % 2) != 1
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      y.even?
    RUBY
  end

  it 'converts (x.y % 2) != 1 to #even?' do
    expect_offense(<<~RUBY)
      (x.y % 2) != 1
      ^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x.y.even?
    RUBY
  end

  it 'converts (x(y) % 2) != 1 to #even?' do
    expect_offense(<<~RUBY)
      (x(y) % 2) != 1
      ^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x(y).even?
    RUBY
  end

  it 'wraps an operator receiver in parentheses when converting a * b % 2 == 0' do
    expect_offense(<<~RUBY)
      a * b % 2 == 0
      ^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      (a * b).even?
    RUBY
  end

  it 'wraps a unary operator receiver in parentheses' do
    expect_offense(<<~RUBY)
      -a % 2 == 0
      ^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      (-a).even?
    RUBY
  end

  it 'does not add parentheses around an index receiver' do
    expect_offense(<<~RUBY)
      a[0] % 2 == 0
      ^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      a[0].even?
    RUBY
  end

  it 'accepts x % 2 == 2' do
    expect_no_offenses('x % 2 == 2')
  end

  it 'accepts x % 3 == 0' do
    expect_no_offenses('x % 3 == 0')
  end

  it 'accepts x % 3 != 0' do
    expect_no_offenses('x % 3 != 0')
  end

  it 'converts (x._(y) % 2) != 1 to even?' do
    expect_offense(<<~RUBY)
      (x._(y) % 2) != 1
      ^^^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x._(y).even?
    RUBY
  end

  it 'converts (x._(y)) % 2 != 1 to even?' do
    expect_offense(<<~RUBY)
      (x._(y)) % 2 != 1
      ^^^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      (x._(y)).even?
    RUBY
  end

  it 'converts x._(y) % 2 != 1 to even?' do
    expect_offense(<<~RUBY)
      x._(y) % 2 != 1
      ^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      x._(y).even?
    RUBY
  end

  it 'converts 1 % 2 != 1 to even?' do
    expect_offense(<<~RUBY)
      1 % 2 != 1
      ^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY

    expect_correction(<<~RUBY)
      1.even?
    RUBY
  end

  it 'converts complex examples' do
    expect_offense(<<~RUBY)
      if (y % 2) != 1
         ^^^^^^^^^^^^ Replace with `Integer#even?`.
        method == :== ? :even : :odd
      elsif x % 2 == 1
            ^^^^^^^^^^ Replace with `Integer#odd?`.
        method == :== ? :odd : :even
      end
    RUBY

    expect_correction(<<~RUBY)
      if y.even?
        method == :== ? :even : :odd
      elsif x.odd?
        method == :== ? :odd : :even
      end
    RUBY
  end
end
