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
end
