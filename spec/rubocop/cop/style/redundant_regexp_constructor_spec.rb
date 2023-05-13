# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpConstructor, :config do
  it 'registers an offense when wrapping `/regexp/` with `Regexp.new`' do
    expect_offense(<<~RUBY)
      Regexp.new(/regexp/)
      ^^^^^^^^^^^^^^^^^^^^ Remove the redundant `Regexp.new`.
    RUBY

    expect_correction(<<~RUBY)
      /regexp/
    RUBY
  end

  it 'registers an offense when wrapping `/regexp/` with `::Regexp.new`' do
    expect_offense(<<~RUBY)
      ::Regexp.new(/regexp/)
      ^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `Regexp.new`.
    RUBY

    expect_correction(<<~RUBY)
      /regexp/
    RUBY
  end

  it 'registers an offense when wrapping `/regexp/i` with `Regexp.new`' do
    expect_offense(<<~RUBY)
      Regexp.new(/regexp/i)
      ^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `Regexp.new`.
    RUBY

    expect_correction(<<~RUBY)
      /regexp/i
    RUBY
  end

  it 'registers an offense when wrapping `/\A#{regexp}\z/io` with `Regexp.new`' do
    expect_offense(<<~'RUBY')
      Regexp.new(/\A#{regexp}\z/io)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `Regexp.new`.
    RUBY

    expect_correction(<<~'RUBY')
      /\A#{regexp}\z/io
    RUBY
  end

  it 'registers an offense when wrapping `/regexp/` with `Regexp.compile`' do
    expect_offense(<<~RUBY)
      Regexp.compile(/regexp/)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `Regexp.compile`.
    RUBY

    expect_correction(<<~RUBY)
      /regexp/
    RUBY
  end

  it 'does not register an offense when wrapping a string literal with `Regexp.new`' do
    expect_no_offenses(<<~RUBY)
      Regexp.new('regexp')
    RUBY
  end

  it 'does not register an offense when wrapping a string literal with `Regexp.new` with regopt argument' do
    expect_no_offenses(<<~RUBY)
      Regexp.new('regexp', Regexp::IGNORECASE)
    RUBY
  end

  it 'does not register an offense when wrapping a string literal with `Regexp.new` with piped regopt argument' do
    expect_no_offenses(<<~RUBY)
      Regexp.new('regexp', Regexp::IGNORECASE | Regexp::IGNORECASE)
    RUBY
  end

  it 'does not register an offense when wrapping a string literal with `Regexp.compile`' do
    expect_no_offenses(<<~RUBY)
      Regexp.compile('regexp')
    RUBY
  end

  it 'does not register an offense when using a regexp literal' do
    expect_no_offenses(<<~RUBY)
      /regexp/
    RUBY
  end
end
