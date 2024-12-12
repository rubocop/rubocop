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

  it 'registers an offense when using `string === /\Astring\z/`' do
    expect_offense(<<~'RUBY')
      string === /\Astring\z/
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `string == 'string'`.
    RUBY

    expect_correction(<<~RUBY)
      string == 'string'
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

  it 'does not register an offense when using `string === /\A0+\z/` (literal with quantifier)' do
    expect_no_offenses(<<~'RUBY')
      string === /\A0+\z/
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
end
