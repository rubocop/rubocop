# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MixedCaseRange, :config do
  let(:message) do
    'Ranges from upper to lower case ASCII letters may include unintended ' \
      'characters. Instead of `A-z` (which also includes several symbols) ' \
      'specify each range individually: `A-Za-z` and individually specify any symbols.'
  end

  it 'registers an offense for an overly broad character range' do
    expect_offense(<<~RUBY)
      foo = 'A'..'z'
            ^^^^^^^^ #{message}
    RUBY
  end

  it 'registers an offense for an overly broad exclusive character range' do
    expect_offense(<<~RUBY)
      foo = 'A'...'z'
            ^^^^^^^^^ #{message}
    RUBY
  end

  it 'does not register an offense for an acceptable range' do
    expect_no_offenses(<<~RUBY)
      foo = 'A'..'Z'
    RUBY
  end

  it 'does not register an offense when the number of characters at the start of range is other than 1' do
    expect_no_offenses(<<~RUBY)
      foo = 'aa'..'z'
    RUBY
  end

  it 'does not register an offense when the number of characters at the end of range is other than 1' do
    expect_no_offenses(<<~RUBY)
      foo = 'a'..'zz'
    RUBY
  end

  context 'ruby > 2.6', :ruby27 do
    it 'does not register an offense for a beginless range' do
      expect_no_offenses(<<~RUBY)
        (..'z')
      RUBY
    end
  end

  it 'does not register an offense for an endless range' do
    expect_no_offenses(<<~RUBY)
      ('a'..)
    RUBY
  end

  it 'registers an offense for an overly broad range' do
    expect_offense(<<~RUBY)
      foo = /[A-z]/
              ^^^ #{message}
    RUBY

    expect_correction(<<~RUBY)
      foo = /[A-Za-z]/
    RUBY
  end

  it 'registers an offense for an overly broad range between interpolations' do
    expect_offense(<<~'RUBY'.sub(/\#{message}/, message))
      foo = /[#{A-z}A-z#{y}]/
                    ^^^ #{message}
    RUBY

    expect_correction(<<~'RUBY')
      foo = /[#{A-z}A-Za-z#{y}]/
    RUBY
  end

  it 'registers an offense for each of multiple unsafe ranges' do
    expect_offense(<<~RUBY)
      foo = /[_A-b;Z-a!]/
                   ^^^ #{message}
               ^^^ #{message}
    RUBY

    expect_correction(<<~RUBY)
      foo = /[_A-Za-b;Za!]/
    RUBY
  end

  it 'registers an offense for each of multiple unsafe ranges at the correct place' do
    expect_offense(<<~RUBY)
      foo = %r{[A-z]+/[A-z]+|all}.freeze || /_[A-z]/
                                               ^^^ #{message}
                       ^^^ #{message}
                ^^^ #{message}
    RUBY

    expect_correction(<<~RUBY)
      foo = %r{[A-Za-z]+/[A-Za-z]+|all}.freeze || /_[A-Za-z]/
    RUBY
  end

  it 'registers an offense in an extended regexp' do
    expect_offense(<<~RUBY)
      foo = /
        A-z # not a character class
        [A-z]_..._
         ^^^ #{message}
      /x
    RUBY

    expect_correction(<<~RUBY)
      foo = /
        A-z # not a character class
        [A-Za-z]_..._
      /x
    RUBY
  end

  it 'registers an offense for nested (intersected) unsafe ranges' do
    expect_offense(<<~RUBY)
      foo = /[_A-z;&&[^G-f]]/
                       ^^^ #{message}
               ^^^ #{message}
    RUBY

    expect_correction(<<~RUBY)
      foo = /[_A-Za-z;&&[^G-Za-f]]/
    RUBY
  end

  it 'registers an offense for unsafe range with possible octal digits following' do
    expect_offense(<<~RUBY)
      foo = /[_A-z123]/
               ^^^ #{message}
    RUBY

    expect_correction(<<~RUBY)
      foo = /[_A-Za-z123]/
    RUBY
  end

  it 'registers an offense for unsafe range with full octal escape preceeding' do
    expect_offense(<<~'RUBY'.sub(/\#{message}/, message))
      foo = /[\001A-z123]/
                  ^^^ #{message}
    RUBY

    expect_correction(<<~'RUBY')
      foo = /[\001A-Za-z123]/
    RUBY
  end

  it 'registers an offense for unsafe range with short octal escape preceeding' do
    expect_offense(<<~'RUBY'.sub(/\#{message}/, message))
      foo = /[\1A-z123]/
                ^^^ #{message}
    RUBY

    expect_correction(<<~'RUBY')
      foo = /[\1A-Za-z123]/
    RUBY
  end

  it 'does not register an offense for accepted ranges' do
    expect_no_offenses(<<~RUBY)
      foo = /[_a-zA-Z0-9;]/
    RUBY
  end

  it 'does not register an offense with escaped octal opening bound' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\101-z]/
    RUBY
  end

  it 'does not register an offense with escaped octal closing bound' do
    expect_no_offenses(<<~'RUBY')
      foo = /[A-\172]/
    RUBY
  end

  it 'does not register an offense with opening hex bound' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\x01-z]/
    RUBY
  end

  it 'does not register an offense with closing hex bound' do
    expect_no_offenses(<<~'RUBY')
      foo = /[A-\x7a]/
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

  it 'does not register an offense with nested character class' do
    expect_no_offenses(<<~RUBY)
      foo = /[a-[bc]]/
    RUBY
  end

  it 'does not register an offense when a character between `Z` and `a` is at the start of range.' do
    expect_no_offenses(<<~RUBY)
      foo = /[_-a]/
    RUBY
  end

  it 'does not register an offense when a character between `Z` and `a` is at the end of range.' do
    expect_no_offenses(<<~RUBY)
      foo = /[A-_]/
    RUBY
  end

  it 'does not register an offense with invalid byte sequence in UTF-8' do
    expect_no_offenses(<<~'RUBY')
      foo = /[\–]/
    RUBY
  end
end
