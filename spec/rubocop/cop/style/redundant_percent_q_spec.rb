# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantPercentQ, :config do
  context 'with %q strings' do
    it 'registers an offense for only single quotes' do
      expect_offense(<<~RUBY)
        %q('hi')
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY

      expect_correction(<<~RUBY)
        "'hi'"
      RUBY
    end

    it 'registers an offense for only double quotes' do
      expect_offense(<<~RUBY)
        %q("hi")
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY

      expect_correction(<<~RUBY)
        '"hi"'
      RUBY
    end

    it 'registers an offense for no quotes' do
      expect_offense(<<~RUBY)
        %q(hi)
        ^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY

      expect_correction(<<~RUBY)
        'hi'
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      expect_no_offenses("%q('\"hi\"')")
    end

    it 'registers an offense for a string containing escaped backslashes' do
      expect_offense(<<~'RUBY')
        %q(\\\\foo\\\\)
        ^^^^^^^^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY

      expect_correction(<<~'RUBY')
        '\\\\foo\\\\'
      RUBY
    end

    it 'accepts a string with escaped non-backslash characters' do
      expect_no_offenses("%q(\\'foo\\')")
    end

    it 'accepts a string with escaped backslash and non-backslash characters' do
      expect_no_offenses("%q(\\\\ \\'foo\\' \\\\)")
    end

    it 'accepts regular expressions starting with %q' do
      expect_no_offenses('/%q?/')
    end

    it 'autocorrects for strings that are concatenated with backslash' do
      expect_offense(<<~'RUBY')
        %q(foo bar baz) \
        ^^^^^^^^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
          'boogers'
      RUBY

      expect_correction(<<~'RUBY')
        'foo bar baz' \
          'boogers'
      RUBY
    end
  end

  context 'with %Q strings' do
    it 'registers an offense for static string without quotes' do
      expect_offense(<<~RUBY)
        %Q(hi)
        ^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY

      expect_correction(<<~RUBY)
        "hi"
      RUBY
    end

    it 'registers an offense for static string with only double quotes' do
      expect_offense(<<~RUBY)
        %Q("hi")
        ^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY

      expect_correction(<<~RUBY)
        '"hi"'
      RUBY
    end

    it 'registers an offense for dynamic string without quotes' do
      expect_offense(<<~'RUBY')
        %Q(hi#{4})
        ^^^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY

      expect_correction(<<~'RUBY')
        "hi#{4}"
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      expect_no_offenses("%Q('\"hi\"')")
    end

    it 'accepts a string with double quotes and an escaped special character' do
      expect_no_offenses('%Q("\\thi")')
    end

    it 'accepts a string with double quotes and an escaped normal character' do
      expect_no_offenses('%Q("\\!thi")')
    end

    it 'accepts a dynamic %Q string with double quotes' do
      expect_no_offenses("%Q(\"hi\#{4}\")")
    end

    it 'accepts regular expressions starting with %Q' do
      expect_no_offenses('/%Q?/')
    end

    it 'autocorrects for strings that are concatenated with backslash' do
      expect_offense(<<~'RUBY')
        %Q(foo bar baz) \
        ^^^^^^^^^^^^^^^ Use `%Q` only for strings that contain both single [...]
          'boogers'
      RUBY

      expect_correction(<<~'RUBY')
        "foo bar baz" \
          'boogers'
      RUBY
    end
  end

  it 'accepts a heredoc string that contains %q' do
    expect_no_offenses(<<~RUBY)
        s = <<CODE
      %q('hi') # line 1
      %q("hi")
      CODE
    RUBY
  end

  it 'accepts %q at the beginning of a double quoted string with interpolation' do
    expect_no_offenses("\"%q(a)\#{b}\"")
  end

  it 'accepts %Q at the beginning of a double quoted string with interpolation' do
    expect_no_offenses("\"%Q(a)\#{b}\"")
  end

  it 'accepts %q at the beginning of a section of a double quoted string with interpolation' do
    expect_no_offenses(%("%\#{b}%q(a)"))
  end

  it 'accepts %Q at the beginning of a section of a double quoted string with interpolation' do
    expect_no_offenses(%("%\#{b}%Q(a)"))
  end

  it 'accepts %q containing string interpolation' do
    expect_no_offenses("%q(foo \#{'bar'} baz)")
  end
end
