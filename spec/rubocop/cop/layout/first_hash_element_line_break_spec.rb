# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstHashElementLineBreak, :config do
  it 'registers an offense and corrects elements listed on the first line' do
    expect_offense(<<~RUBY)
      a = { a: 1,
            ^^^^ Add a line break before the first element of a multi-line hash.
            b: 2 }
    RUBY

    expect_correction(<<~RUBY)
      a = {#{trailing_whitespace}
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
      method({#{trailing_whitespace}
      foo: 1,
               bar: 2 })
    RUBY
  end

  it 'registers an offense and corrects single element multi-line hash' do
    expect_offense(<<~RUBY)
      { foo: {
        ^^^^^^ Add a line break before the first element of a multi-line hash.
        bar: 2,
      } }
    RUBY

    expect_correction(<<~RUBY)
      {#{trailing_whitespace}
      foo: {
        bar: 2,
      } }
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

  context 'last element can be multiline' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last argument that is a multiline Hash' do
      expect_no_offenses(<<~RUBY)
        h = {a: b, c: {
          d: e
        }}
      RUBY
    end

    it 'ignores single value that is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        h = {a: {
          b: c
        }}
      RUBY
    end

    it 'registers and corrects values that are multiline hashes and not the last value' do
      expect_offense(<<~RUBY)
        h = {a: b, c: {
             ^^^^ Add a line break before the first element of a multi-line hash.
          d: e,
        }, f: g}
      RUBY

      expect_correction(<<~RUBY)
        h = {
        a: b, c: {
          d: e,
        }, f: g}
      RUBY
    end

    it 'registers and corrects last value that starts on another line' do
      expect_offense(<<~RUBY)
        h = {a: b, c: d,
             ^^^^ Add a line break before the first element of a multi-line hash.
        e: f}
      RUBY

      expect_correction(<<~RUBY)
        h = {
        a: b, c: d,
        e: f}
      RUBY
    end
  end
end
