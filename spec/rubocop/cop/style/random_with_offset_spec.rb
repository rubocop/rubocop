# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RandomWithOffset, :config do
  it 'registers an offense when using rand(int) + offset' do
    expect_offense(<<~RUBY)
      rand(6) + 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'registers an offense when using offset + rand(int)' do
    expect_offense(<<~RUBY)
      1 + rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'registers an offense when using rand(int).succ' do
    expect_offense(<<~RUBY)
      rand(6).succ
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'registers an offense when using rand(int) - offset' do
    expect_offense(<<~RUBY)
      rand(6) - 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-1..4)
    RUBY
  end

  it 'registers an offense when using offset - rand(int)' do
    expect_offense(<<~RUBY)
      1 - rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-4..1)
    RUBY
  end

  it 'registers an offense when using rand(int).pred' do
    expect_offense(<<~RUBY)
      rand(6).pred
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-1..4)
    RUBY
  end

  it 'registers an offense when using rand(int).next' do
    expect_offense(<<~RUBY)
      rand(6).next
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'registers an offense when using Kernel.rand' do
    expect_offense(<<~RUBY)
      Kernel.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      Kernel.rand(1..6)
    RUBY
  end

  it 'registers an offense when using ::Kernel.rand' do
    expect_offense(<<~RUBY)
      ::Kernel.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      ::Kernel.rand(1..6)
    RUBY
  end

  it 'registers an offense when using Random.rand' do
    expect_offense(<<~RUBY)
      Random.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      Random.rand(1..6)
    RUBY
  end

  it 'registers an offense when using ::Random.rand' do
    expect_offense(<<~RUBY)
      ::Random.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      ::Random.rand(1..6)
    RUBY
  end

  it 'registers an offense when using rand(irange) + offset' do
    expect_offense(<<~RUBY)
      rand(0..6) + 1
      ^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..7)
    RUBY
  end

  it 'registers an offense when using rand(erange) + offset' do
    expect_offense(<<~RUBY)
      rand(0...6) + 1
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'registers an offense when using offset + Random.rand(int)' do
    expect_offense(<<~RUBY)
      1 + Random.rand(6)
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      Random.rand(1..6)
    RUBY
  end

  it 'registers an offense when using offset - ::Random.rand(int)' do
    expect_offense(<<~RUBY)
      1 - ::Random.rand(6)
      ^^^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      ::Random.rand(-4..1)
    RUBY
  end

  it 'registers an offense when using Random.rand(int).succ' do
    expect_offense(<<~RUBY)
      Random.rand(6).succ
      ^^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      Random.rand(1..6)
    RUBY
  end

  it 'registers an offense when using ::Random.rand(int).pred' do
    expect_offense(<<~RUBY)
      ::Random.rand(6).pred
      ^^^^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      ::Random.rand(-1..4)
    RUBY
  end

  it 'registers an offense when using rand(irange) - offset' do
    expect_offense(<<~RUBY)
      rand(0..6) - 1
      ^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-1..5)
    RUBY
  end

  it 'registers an offense when using rand(erange) - offset' do
    expect_offense(<<~RUBY)
      rand(0...6) - 1
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-1..4)
    RUBY
  end

  it 'registers an offense when using offset - rand(irange)' do
    expect_offense(<<~RUBY)
      1 - rand(0..6)
      ^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-5..1)
    RUBY
  end

  it 'registers an offense when using offset - rand(erange)' do
    expect_offense(<<~RUBY)
      1 - rand(0...6)
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(-4..1)
    RUBY
  end

  it 'registers an offense when using rand(irange).succ' do
    expect_offense(<<~RUBY)
      rand(0..6).succ
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..7)
    RUBY
  end

  it 'registers an offense when using rand(erange).succ' do
    expect_offense(<<~RUBY)
      rand(0...6).succ
      ^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
    RUBY

    expect_correction(<<~RUBY)
      rand(1..6)
    RUBY
  end

  it 'does not register an offense when using rand(irange) + offset with a non-integer range value' do
    expect_no_offenses(<<~RUBY)
      rand(0..limit) + 1
    RUBY
  end

  it 'does not register an offense when using offset - rand(erange) with a non-integer range value' do
    expect_no_offenses(<<~RUBY)
      1 - rand(0...limit)
    RUBY
  end

  it 'does not register an offense when using rand(irange).succ with a non-integer range value' do
    expect_no_offenses(<<~RUBY)
      rand(0..limit).succ
    RUBY
  end

  it 'does not register an offense when using rand(erange).pred with a non-integer range value' do
    expect_no_offenses(<<~RUBY)
      rand(0...limit).pred
    RUBY
  end

  it 'does not register an offense when using range with double dots' do
    expect_no_offenses('rand(1..6)')
  end

  it 'does not register an offense when using range with triple dots' do
    expect_no_offenses('rand(1...6)')
  end
end
