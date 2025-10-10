# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FloatPrecision, :config do
  it 'does not register an offense for simple floats that preserve precision' do
    expect_no_offenses(<<~RUBY)
      0.0
      0.0000204894
      -0.00001
      0.1
      1.0
      +1.0
      -1.0
      1.1
      10000.0
      10000.0000
      100000000000000000.0
      -100000000000000000.0
    RUBY
  end

  it 'does not register an offense for scientific notation floats that preserve precision' do
    expect_no_offenses(<<~RUBY)
      0E0
      25e-6
      0.1e1
      0.01e1
      0.001e1
      0.0001e1
      0.00001e1
      0E10
      0.0E10
      1E10
      1.0E100
      +1.0e+1
    RUBY
  end

  it 'does not register an offense for simple floats with underscores that preserve precision' do
    expect_no_offenses(<<~RUBY)
      1_000.0
      1_000.0_1
      123_456.789_123
    RUBY
  end

  it 'does not register an offense for scientific notation floats with underscores that preserve precision' do
    expect_no_offenses(<<~RUBY)
      1_0E0
      1_0.0E10
      1_0.0_1E10
      1.0_0E0
      1.0E1_0
    RUBY
  end

  it 'registers an offense for precision loss past the decimal' do
    expect_offense(<<~RUBY)
      100000000000.000000000001
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `100000000000.0`.
      +100000000000.000000000001
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `100000000000.0`.
      -100000000000.000000000001
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `-100000000000.0`.
      100_000_000_000.000_000_000_001
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `100000000000.0`.
    RUBY
  end

  it 'registers an offense for large integers that lose precision' do
    expect_offense(<<~RUBY)
      10000000000000001.0
      ^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `10000000000000000.0`.
      -10000000000000001.0
      ^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `-10000000000000000.0`.
      +10000000000000001.0
      ^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `10000000000000000.0`.
      10_000_000_000_000_001.0
      ^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `10000000000000000.0`.
    RUBY
  end

  it 'registers an offense for scientific notation that loses precision' do
    expect_offense(<<~RUBY)
      1234567890123456789e10
      ^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `12345678901234568000000000000.0`.
      1234567890123456789E10
      ^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `12345678901234568000000000000.0`.
      +1234567890123456789e+10
      ^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `12345678901234568000000000000.0`.
      1_234_567_890_123_456_789e1_000
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `Infinity`.
    RUBY
  end

  it 'registers an offense for very long decimal numbers' do
    expect_offense(<<~RUBY)
      1.2345678901234567890123456789
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `1.2345678901234567`.
      1.234_567_890_123_456_789_012_345_678_9
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Float literal is not precisely representable and becomes `1.2345678901234567`.
    RUBY
  end
end
