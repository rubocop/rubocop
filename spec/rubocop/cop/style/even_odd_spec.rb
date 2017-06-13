# frozen_string_literal: true

describe RuboCop::Cop::Style::EvenOdd do
  subject(:cop) { described_class.new }

  it 'registers an offense for x % 2 == 0' do
    expect_offense(<<-RUBY.strip_indent)
      x % 2 == 0
      ^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'registers an offense for x % 2 != 0' do
    expect_offense(<<-RUBY.strip_indent)
      x % 2 != 0
      ^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY
  end

  it 'registers an offense for (x % 2) == 0' do
    expect_offense(<<-RUBY.strip_indent)
      (x % 2) == 0
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'registers an offense for (x % 2) != 0' do
    expect_offense(<<-RUBY.strip_indent)
      (x % 2) != 0
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY
  end

  it 'registers an offense for x % 2 == 1' do
    expect_offense(<<-RUBY.strip_indent)
      x % 2 == 1
      ^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY
  end

  it 'registers an offense for x % 2 != 1' do
    expect_offense(<<-RUBY.strip_indent)
      x % 2 != 1
      ^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'registers an offense for (x % 2) == 1' do
    expect_offense(<<-RUBY.strip_indent)
      (x % 2) == 1
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
    RUBY
  end

  it 'registers an offense for (x % 2) != 1' do
    expect_offense(<<-RUBY.strip_indent)
      (x % 2) != 1
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'registers an offense for (x.y % 2) != 1' do
    expect_offense(<<-RUBY.strip_indent)
      (x.y % 2) != 1
      ^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'registers an offense for (x(y) % 2) != 1' do
    expect_offense(<<-RUBY.strip_indent)
      (x(y) % 2) != 1
      ^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
    RUBY
  end

  it 'accepts x % 3 == 0' do
    expect_no_offenses('x % 3 == 0')
  end

  it 'accepts x % 3 != 0' do
    expect_no_offenses('x % 3 != 0')
  end

  it 'converts x % 2 == 0 to #even?' do
    corrected = autocorrect_source('x % 2 == 0')
    expect(corrected).to eq('x.even?')
  end

  it 'converts x % 2 != 0 to #odd?' do
    corrected = autocorrect_source('x % 2 != 0')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts (x % 2) == 0 to #even?' do
    corrected = autocorrect_source('(x % 2) == 0')
    expect(corrected).to eq('x.even?')
  end

  it 'converts (x % 2) != 0 to #odd?' do
    corrected = autocorrect_source('(x % 2) != 0')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts x % 2 == 1 to odd?' do
    corrected = autocorrect_source('x % 2 == 1')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts x % 2 != 1 to even?' do
    corrected = autocorrect_source('x % 2 != 1')
    expect(corrected).to eq('x.even?')
  end

  it 'converts (x % 2) == 1 to odd?' do
    corrected = autocorrect_source('(x % 2) == 1')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts (y % 2) != 1 to even?' do
    corrected = autocorrect_source('(y % 2) != 1')
    expect(corrected).to eq('y.even?')
  end

  it 'converts (x.y % 2) != 1 to even?' do
    corrected = autocorrect_source('(x.y % 2) != 1')
    expect(corrected).to eq('x.y.even?')
  end

  it 'converts (x(y) % 2) != 1 to even?' do
    corrected = autocorrect_source('(x(y) % 2) != 1')
    expect(corrected).to eq('x(y).even?')
  end

  it 'converts (x._(y) % 2) != 1 to even?' do
    corrected = autocorrect_source('(x._(y) % 2) != 1')
    expect(corrected).to eq('x._(y).even?')
  end

  it 'converts (x._(y)) % 2 != 1 to even?' do
    corrected = autocorrect_source('(x._(y)) % 2 != 1')
    expect(corrected).to eq('(x._(y)).even?')
  end

  it 'converts x._(y) % 2 != 1 to even?' do
    corrected = autocorrect_source('x._(y) % 2 != 1')
    expect(corrected).to eq('x._(y).even?')
  end

  it 'converts 1 % 2 != 1 to even?' do
    corrected = autocorrect_source('1 % 2 != 1')
    expect(corrected).to eq('1.even?')
  end

  it 'converts complex examples' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      if (y % 2) != 1
        method == :== ? :even : :odd
      elsif x % 2 == 1
        method == :== ? :odd : :even
      end
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      if y.even?
        method == :== ? :even : :odd
      elsif x.odd?
        method == :== ? :odd : :even
      end
    RUBY
  end
end
