# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstHashElementLineBreak do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects elements listed on the first line' do
    expect_offense(<<~RUBY)
      a = { a: 1,
            ^^^^ Add a line break before the first element of a multi-line hash.
            b: 2 }
    RUBY

    expect_correction(<<~RUBY)
      a = { 
      a: 1,
            b: 2 }
    RUBY
  end

  it 'registers an offense and corrects hash nested in a method call' do
    expect_offense(<<~RUBY)
      method({ foo: 1,
               ^^^^^^ Add a line break before the first element of a multi-line hash.
               bar: 2 })
    RUBY

    expect_correction(<<~RUBY)
      method({ 
      foo: 1,
               bar: 2 })
    RUBY
  end

  it 'ignores implicit hashes in method calls with parens' do
    expect_no_offenses(<<~RUBY)
      method(
        foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores implicit hashes in method calls without parens' do
    expect_no_offenses(<<~RUBY)
      method foo: 1,
       bar: 2
    RUBY
  end

  it 'ignores implicit hashes in method calls that are improperly formatted' do
    # These are covered by Style/FirstMethodArgumentLineBreak
    expect_no_offenses(<<~RUBY)
      method(foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores elements listed on a single line' do
    expect_no_offenses(<<~RUBY)
      b = {
        a: 1,
        b: 2 }
    RUBY
  end
end
