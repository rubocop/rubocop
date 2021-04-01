# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BigDecimalNew, :config do
  it 'registers an offense and corrects using `BigDecimal.new()`' do
    expect_offense(<<~RUBY)
      BigDecimal.new(123.456, 3)
                 ^^^ `BigDecimal.new()` is deprecated. Use `BigDecimal()` instead.
    RUBY

    expect_correction(<<~RUBY)
      BigDecimal(123.456, 3)
    RUBY
  end

  it 'registers an offense and corrects using `::BigDecimal.new()`' do
    expect_offense(<<~RUBY)
      ::BigDecimal.new(123.456, 3)
                   ^^^ `::BigDecimal.new()` is deprecated. Use `::BigDecimal()` instead.
    RUBY

    expect_correction(<<~RUBY)
      ::BigDecimal(123.456, 3)
    RUBY
  end

  it 'does not register an offense when using `BigDecimal()`' do
    expect_no_offenses(<<~RUBY)
      BigDecimal(123.456, 3)
    RUBY
  end
end
