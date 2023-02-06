# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantHeredocDelimiterQuotes, :config do
  it 'registers an offense when using the redundant heredoc delimiter single quotes with `<<~`' do
    expect_offense(<<~RUBY)
      do_something(<<~'EOS')
                   ^^^^^^^^ Remove the redundant heredoc delimiter quotes, use `<<~EOS` instead.
        no string interpolation style text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something(<<~EOS)
        no string interpolation style text
      EOS
    RUBY
  end

  it 'registers an offense when using the redundant heredoc delimiter single quotes with `<<-`' do
    expect_offense(<<~RUBY)
      do_something(<<-'EOS')
                   ^^^^^^^^ Remove the redundant heredoc delimiter quotes, use `<<-EOS` instead.
        no string interpolation style text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something(<<-EOS)
        no string interpolation style text
      EOS
    RUBY
  end

  it 'registers an offense when using the redundant heredoc delimiter single quotes with `<<`' do
    expect_offense(<<~RUBY)
      do_something(<<'EOS')
                   ^^^^^^^ Remove the redundant heredoc delimiter quotes, use `<<EOS` instead.
        no string interpolation style text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something(<<EOS)
        no string interpolation style text
      EOS
    RUBY
  end

  it 'registers an offense when using the redundant heredoc delimiter double quotes' do
    expect_offense(<<~RUBY)
      do_something(<<~"EOS")
                   ^^^^^^^^ Remove the redundant heredoc delimiter quotes, use `<<~EOS` instead.
        no string interpolation style text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something(<<~EOS)
        no string interpolation style text
      EOS
    RUBY
  end

  it 'does not register an offense when using the redundant heredoc delimiter backquotes' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~`EOS`)
        command
      EOS
    RUBY
  end

  it 'does not register an offense when not using the redundant heredoc delimiter quotes' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~EOS)
        no string interpolation style text
      EOS
    RUBY
  end

  it 'does not register an offense when using the quoted heredoc with string interpolation style text' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        #{string} #{interpolation}
      EOS
    RUBY
  end

  it 'does not register an offense when using the quoted heredoc with multiline string interpolation style text' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        #{
          string
        } #{
          interpolation
        }
      EOS
    RUBY
  end

  it 'does not register an offense when using the quoted heredoc with instance variable string interpolation' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        #@foo
      EOS
    RUBY
  end

  it 'does not register an offense when using the quoted heredoc with class variable string interpolation' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        #@@foo
      EOS
    RUBY
  end

  it 'does not register an offense when using the quoted heredoc with global variable string interpolation' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        #$foo
      EOS
    RUBY
  end

  it 'does not register an offense when using the heredoc delimiter with double quote' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~'EDGE"CASE')
        no string interpolation style text
      EDGE"CASE
    RUBY
  end

  it 'does not register an offense when using the heredoc delimiter with single quote' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~"EDGE'CASE")
        no string interpolation style text
      EDGE'CASE
    RUBY
  end

  it 'does not register an offense when using the heredoc delimiter with space' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~'EDGE CASE')
        no string interpolation style text
      EDGE CASE
    RUBY
  end

  it 'does not register an offense when using the heredoc delimiter with multibyte space' do
    expect_no_offenses(<<~RUBY)
      do_something(<<~'EDGE　CASE')
        no string interpolation style text
      EDGE　CASE
    RUBY
  end

  it 'does not register an offense when using the heredoc delimiter with backslash' do
    expect_no_offenses(<<~'RUBY')
      do_something(<<~'EOS')
        Preserve \
        newlines
      EOS
    RUBY
  end
end
