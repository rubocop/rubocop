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
