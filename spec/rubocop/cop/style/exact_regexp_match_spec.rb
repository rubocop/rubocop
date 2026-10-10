# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ExactRegexpMatch, :config do
  it 'registers an offense when using `string =~ /\Astring\z/`' do
    expect_offense(<<~'RUBY')
      string =~ /\Astring\z/
      ^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
    RUBY
  end

  it 'escapes single quotes in the corrected string literal' do
    expect_offense(<<~'RUBY')
      string =~ /\Afoo'bar\z/
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'foo\'bar'`.
    RUBY

    expect_correction(<<~'RUBY')
      string == 'foo\'bar'
    RUBY
  end

  it 'registers an offense when using `/\Astring\z/ === string`' do
    expect_offense(<<~'RUBY')
      /\Astring\z/ === string
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
    RUBY
  end

  it 'does not register an offense when using `string === /\Astring\z/`' do
    expect_no_offenses(<<~'RUBY')
      string === /\Astring\z/
    RUBY
  end

  it 'registers an offense when using `string.match(/\Astring\z/)`' do
    expect_offense(<<~'RUBY')
      string.match(/\Astring\z/)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
    RUBY
  end

  it 'registers an offense when using `string&.match(/\Astring\z/)`' do
    expect_offense(<<~'RUBY')
      string&.match(/\Astring\z/)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
    RUBY
  end

  it 'does not register an offense when using match without receiver' do
    expect_no_offenses('match(/\\Astring\\z/)')
  end

  it 'registers an offense when using `string.match?(/\Astring\z/)`' do
    expect_offense(<<~'RUBY')
      string.match?(/\Astring\z/)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
    RUBY
  end

  it 'registers an offense when using `string !~ /\Astring\z/`' do
    expect_offense(<<~'RUBY')
      string !~ /\Astring\z/
      ^^^^^^^^^^^^^^^^^^^^^^ Use `string != 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string != 'string'
    RUBY
  end

  it 'does not register an offense when using `string =~ /\Astring#{interpolation}\z/` (string interpolation)' do
    expect_no_offenses(<<~'RUBY')
      string =~ /\Astring#{interpolation}\z/
    RUBY
  end

  it 'does not register an offense when using `/\A0+\z/ === string` (literal with quantifier)' do
    expect_no_offenses(<<~'RUBY')
      /\A0+\z/ === string
    RUBY
  end

  it 'does not register an offense when using `string =~ /\Astring.*\z/` (any pattern)' do
    expect_no_offenses(<<~'RUBY')
      string =~ /\Astring.*\z/
    RUBY
  end

  it 'does not register an offense when using `string =~ /^string$/` (multiline matches)' do
    expect_no_offenses(<<~RUBY)
      string =~ /^string$/
    RUBY
  end

  it 'does not register an offense when using `string =~ /\Astring\z/i` (regexp opt)' do
    expect_no_offenses(<<~'RUBY')
      string =~ /\Astring\z/i
    RUBY
  end

  context 'invalid regular expressions' do
    around { |example| RuboCop::Util.silence_warnings(&example) }

    it 'does not register an offense for single invalid regexp' do
      expect_no_offenses(<<~'RUBY')
        string =~ /^\P$/
      RUBY
    end

    it 'registers an offense for regexp following invalid regexp' do
      expect_offense(<<~'RUBY')
        string =~ /^\P$/
        string.match(/\Astring\z/)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
      RUBY

      expect_correction(<<~'RUBY')
        string =~ /^\P$/
        string == 'string'
      RUBY
    end
  end

  it 'parenthesizes the comparison when it is negated with `!`' do
    expect_offense(<<~'RUBY')
      !string.match?(/\Astring\z/)
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      !(string == 'string')
    RUBY
  end

  it 'parenthesizes the comparison when a method is called on it' do
    expect_offense(<<~'RUBY')
      string.match?(/\Astring\z/).to_s
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      (string == 'string').to_s
    RUBY
  end

  it 'corrects `match?` when its value is used' do
    expect_offense(<<~'RUBY')
      result = string.match?(/\Astring\z/)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      result = string == 'string'
    RUBY
  end

  it 'corrects `=~` used as a condition' do
    expect_offense(<<~'RUBY')
      do_something if string =~ /\Astring\z/ && other
                      ^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      do_something if string == 'string' && other
    RUBY
  end

  it 'corrects `&.match` used as a negated condition' do
    expect_offense(<<~'RUBY')
      do_something unless !string&.match(/\Astring\z/)
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      do_something unless !(string == 'string')
    RUBY
  end

  it 'does not autocorrect `match` when a method is called on the `MatchData`' do
    expect_offense(<<~'RUBY')
      string.match(/\Astring\z/).nil?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_no_corrections
  end

  it 'does not autocorrect `=~` when its value is used' do
    expect_offense(<<~'RUBY')
      index = string =~ /\Astring\z/
              ^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_no_corrections
  end

  it 'does not autocorrect `=~` when the value of a logical operation it is part of is used' do
    expect_offense(<<~'RUBY')
      result = string =~ /\Astring\z/ && other
               ^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_no_corrections
  end

  it 'does not autocorrect `&.match?` when its value is used' do
    expect_offense(<<~'RUBY')
      result = string&.match?(/\Astring\z/)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_no_corrections
  end
end
