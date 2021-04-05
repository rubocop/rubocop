# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringChars, :config do
  it 'registers and corrects an offense when using `split(//)`' do
    expect_offense(<<~RUBY)
      string.split(//)
             ^^^^^^^^^ Use `chars` instead of `split(//)`.
    RUBY

    expect_correction(<<~RUBY)
      string.chars
    RUBY
  end

  it "registers and corrects an offense when using `split('')`" do
    expect_offense(<<~RUBY)
      string.split('')
             ^^^^^^^^^ Use `chars` instead of `split('')`.
    RUBY

    expect_correction(<<~RUBY)
      string.chars
    RUBY
  end

  it 'registers and corrects an offense when using `split("")`' do
    expect_offense(<<~RUBY)
      string.split("")
             ^^^^^^^^^ Use `chars` instead of `split("")`.
    RUBY

    expect_correction(<<~RUBY)
      string.chars
    RUBY
  end

  it 'registers and corrects an offense when using `split` without parentheses' do
    expect_offense(<<~RUBY)
      do_something { |foo| foo.split '' }
                               ^^^^^^^^ Use `chars` instead of `split ''`.
    RUBY

    expect_correction(<<~RUBY)
      do_something { |foo| foo.chars }
    RUBY
  end

  it 'does not register an offense when using `chars`' do
    expect_no_offenses(<<~RUBY)
      string.chars
    RUBY
  end

  it 'does not register an offense when using `split(/ /)`' do
    expect_no_offenses(<<~RUBY)
      string.split(/ /)
    RUBY
  end

  it 'does not register an offense when using `split`' do
    expect_no_offenses(<<~RUBY)
      string.split
    RUBY
  end
end
