# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideRangeLiteral, :config do
  it 'registers an offense for space inside .. literal' do
    expect_offense(<<~RUBY)
      1 .. 2
      ^^^^^^ Space inside range literal.
      1.. 2
      ^^^^^ Space inside range literal.
      1 ..2
      ^^^^^ Space inside range literal.
    RUBY

    expect_correction(<<~RUBY)
      1..2
      1..2
      1..2
    RUBY
  end

  it 'accepts no space inside .. literal' do
    expect_no_offenses('1..2')
  end

  it 'registers an offense for space inside ... literal' do
    expect_offense(<<~RUBY)
      1 ... 2
      ^^^^^^^ Space inside range literal.
      1... 2
      ^^^^^^ Space inside range literal.
      1 ...2
      ^^^^^^ Space inside range literal.
    RUBY

    expect_correction(<<~RUBY)
      1...2
      1...2
      1...2
    RUBY
  end

  it 'accepts no space inside ... literal' do
    expect_no_offenses('1...2')
  end

  it 'accepts complex range literal with space in it' do
    expect_no_offenses('0...(line - 1)')
  end

  it 'does not register an offense for spaces around a nested endless range in an operand' do
    expect_no_offenses(<<~RUBY)
      foo..bar[ 1.. ]
    RUBY
  end

  it 'registers an offense only for the range with spaces when an operand has a nested range' do
    expect_offense(<<~RUBY)
      foo .. bar[1..2]
      ^^^^^^^^^^^^^^^^ Space inside range literal.
    RUBY

    expect_correction(<<~RUBY)
      foo..bar[1..2]
    RUBY
  end

  it 'accepts beginless and endless range literals' do
    expect_no_offenses(<<~RUBY)
      foo[..1]
      foo[1..]
    RUBY
  end

  it 'does not register an offense for a space before a comment after a multiline range operator' do
    expect_no_offenses(<<~RUBY)
      x = 0.. # comment
          10
    RUBY
  end

  it 'accepts multiline range literal with no space in it' do
    expect_no_offenses(<<~RUBY)
      x = 0..
          10
    RUBY
  end

  it 'registers an offense in multiline range literal with space in it' do
    expect_offense(<<~RUBY)
      x = 0 ..
          ^^^^ Space inside range literal.
          10
    RUBY

    expect_correction(<<~RUBY)
      x = 0..10
    RUBY
  end
end
