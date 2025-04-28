# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ComparableBetween, :config do
  [
    'x >= min && x <= max',
    'x >= min && max >= x',
    'min <= x && x <= max',
    'min <= x && max >= x',
    'x <= max && x >= min',
    'x <= max && min <= x',
    'max >= x && x >= min',
    'max >= x && min <= x'
  ].each do |logical_comparison|
    it "registers an offense with logical comparison #{logical_comparison}" do
      expect_offense(<<~RUBY)
        #{logical_comparison}
        ^^^^^^^^^^^^^^^^^^^^ Prefer `x.between?(min, max)` over logical comparison.
      RUBY

      expect_correction(<<~RUBY)
        x.between?(min, max)
      RUBY
    end
  end

  it 'registers an offense when using logical comparison with `and`' do
    expect_offense(<<~RUBY)
      x >= min and x <= max
      ^^^^^^^^^^^^^^^^^^^^^ Prefer `x.between?(min, max)` over logical comparison.
    RUBY

    expect_correction(<<~RUBY)
      x.between?(min, max)
    RUBY
  end

  it 'registers an offense when comparing with itself as the min value' do
    expect_offense(<<~RUBY)
      x >= x and x <= max
      ^^^^^^^^^^^^^^^^^^^ Prefer `x.between?(x, max)` over logical comparison.
    RUBY

    expect_correction(<<~RUBY)
      x.between?(x, max)
    RUBY
  end

  it 'registers an offense when comparing with itself as both the min and max value' do
    expect_offense(<<~RUBY)
      x >= x and x <= x
      ^^^^^^^^^^^^^^^^^ Prefer `x.between?(x, x)` over logical comparison.
    RUBY

    expect_correction(<<~RUBY)
      x.between?(x, x)
    RUBY
  end

  it 'does not register an offense when logical comparison excludes max value' do
    expect_no_offenses(<<~RUBY)
      x >= min && x < max
    RUBY
  end

  it 'does not register an offense when logical comparison excludes min value' do
    expect_no_offenses(<<~RUBY)
      x > min && x <= max
    RUBY
  end

  it 'does not register an offense when logical comparison excludes min and max value' do
    expect_no_offenses(<<~RUBY)
      x > min && x < max
    RUBY
  end

  it 'does not register an offense when logical comparison has different subjects for min and max' do
    expect_no_offenses(<<~RUBY)
      x >= min && y <= max
    RUBY
  end
end
