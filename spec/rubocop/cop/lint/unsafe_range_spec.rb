# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnsafeRange, :config do
  it 'registers an offense for an overly broad range' do
    expect_offense(<<~RUBY)
      foo = /[A-z]/
              ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for an overly broad range between interpolations' do
    expect_offense(<<~'RUBY')
      foo = /[#{A-z}A-z#{y}]/
                    ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for a range spanning multiple accepted ranges' do
    expect_offense(<<~RUBY)
      foo = /[0-z]/
              ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for each of multiple unsafe ranges' do
    expect_offense(<<~RUBY)
      foo = /[_A-b;Z-a!]/
                   ^^^ Character range may include unintended characters.
               ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for each of multiple unsafe ranges at the correct place' do
    expect_offense(<<~RUBY)
      foo = %r{[A-z]+/[A-z]+|all}.freeze || /_[A-z]/
                                               ^^^ Character range may include unintended characters.
                       ^^^ Character range may include unintended characters.
                ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense in an extended regexp' do
    expect_offense(<<~RUBY)
      foo = /
        A-z # not a character class
        [A-z]_..._
         ^^^ Character range may include unintended characters.
      /x
    RUBY
  end

  it 'registers an offense for nested (intersected) unsafe ranges' do
    expect_offense(<<~RUBY)
      foo = /[_A-z;&&[^G-f]]/
                       ^^^ Character range may include unintended characters.
               ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for unsafe range with possible octal digits following' do
    expect_offense(<<~RUBY)
      foo = /[_A-z123]/
               ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for unsafe range with full octal escape preceeding' do
    expect_offense(<<~'RUBY')
      foo = /[\001A-z123]/
                  ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'registers an offense for unsafe range with short octal escape preceeding' do
    expect_offense(<<~'RUBY')
      foo = /[\1A-z123]/
                ^^^ Character range may include unintended characters.
    RUBY
  end

  it 'does not register an offense for accepted ranges' do
    expect_no_offenses(<<~RUBY)
      foo = /[_a-zA-Z0-9;]/
    RUBY
  end

  it 'does not register an offense with escaped octal bounds' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\101-\172]/
    RUBY
  end

  it 'does not register an offense with opening octal bound' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\101-z]/
    RUBY
  end

  it 'does not register an offense with escaped hex bounds' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\x41-\x7a]/
    RUBY
  end

  it 'does not register an offense with tricky escaped hex bounds' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\xA-\xf]/
    RUBY
  end

  it 'does not register an offense with escaped unicode bounds' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\u0041-\u007a]/
    RUBY
  end

  it 'does not register an offense with control characters' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\C-A-\cz]/
    RUBY
  end

  it 'does not register an offense with escaped dash (not a range)' do
    expect_no_offenses(<<~'RUBY')
      foo = /[A\-z]/
    RUBY
  end
end
