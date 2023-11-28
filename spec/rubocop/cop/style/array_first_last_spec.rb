# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayFirstLast, :config do
  it 'registers an offense when using `[0]`' do
    expect_offense(<<~RUBY)
      arr[0]
         ^^^ Use `first`.
    RUBY

    expect_correction(<<~RUBY)
      arr.first
    RUBY
  end

  it 'registers an offense when using `[-1]`' do
    expect_offense(<<~RUBY)
      arr[-1]
         ^^^^ Use `last`.
    RUBY

    expect_correction(<<~RUBY)
      arr.last
    RUBY
  end

  it 'does not register an offense when using `[1]`' do
    expect_no_offenses(<<~RUBY)
      arr[1]
    RUBY
  end

  it 'does not register an offense when using `[index]`' do
    expect_no_offenses(<<~RUBY)
      arr[index]
    RUBY
  end

  it 'does not register an offense when using `[0]=`' do
    expect_no_offenses(<<~RUBY)
      arr[0] = 1
    RUBY
  end

  it 'does not register an offense when using `first`' do
    expect_no_offenses(<<~RUBY)
      arr.first
    RUBY
  end

  it 'does not register an offense when using `last`' do
    expect_no_offenses(<<~RUBY)
      arr.last
    RUBY
  end

  it 'does not register an offense when using `[0][0]`' do
    expect_no_offenses(<<~RUBY)
      arr[0][-1]
    RUBY
  end
end
