# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::LineEndConcatenation, :config do
  it 'registers an offense for string concat at line end' do
    expect_offense(<<~RUBY)
      top = "test" +
                   ^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~RUBY)
      top = "test" \\
      "top"
    RUBY
  end

  it 'registers an offense for string concat with << at line end' do
    expect_offense(<<~RUBY)
      top = "test" <<
                   ^^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~RUBY)
      top = "test" \\
      "top"
    RUBY
  end

  it 'registers an offense for string concat with << and \ at line ends' do
    expect_offense(<<~RUBY)
      top = "test " \\
      "foo" <<
            ^^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "bar"
    RUBY

    expect_correction(<<~RUBY)
      top = "test " \\
      "foo" \\
      "bar"
    RUBY
  end

  it 'registers an offense for dynamic string concat at line end' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top"
    RUBY
  end

  it 'registers an offense for dynamic string concat with << at line end' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top"
    RUBY
  end

  it 'registers multiple offenses when there are chained << methods' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" <<
            ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "ubertop"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top" \
      "ubertop"
    RUBY
  end

  it 'registers multiple offenses when there are chained concatenations' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "foo"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top" \
      "foo"
    RUBY
  end

  it 'registers multiple offenses when there are chained concatenations combined with << calls' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "foo" <<
            ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "bar"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top" \
      "foo" \
      "bar"
    RUBY
  end

  it 'accepts string concat on the same line' do
    expect_no_offenses('top = "test" + "top"')
  end

  it 'accepts string concat with a return value of method on a string' do
    expect_no_offenses(<<~RUBY)
      content_and_three_spaces = "content" +
        " " * 3
      a_thing = 'a ' +
        'gniht'.reverse
      output = 'value: ' +
        '%d' % value
      'letter: ' +
        'abcdefghij'[ix]
    RUBY
  end

  it 'accepts string concat with a return value of method on an interpolated string' do
    expect_no_offenses(<<~RUBY)
      x3a = 'x' +
        "\#{'a' + "\#{3}"}".reverse
    RUBY
  end

  it 'accepts string concat at line end when followed by comment' do
    expect_no_offenses(<<~RUBY)
      top = "test" + # something
      "top"
    RUBY
  end

  it 'accepts string concat at line end when followed by a comment line' do
    expect_no_offenses(<<~RUBY)
      top = "test" +
      # something
      "top"
    RUBY
  end

  it 'accepts string concat at line end when % literals are involved' do
    expect_no_offenses(<<~RUBY)
      top = %(test) +
      "top"
    RUBY
  end

  it 'accepts string concat at line end for special strings like __FILE__' do
    expect_no_offenses(<<~RUBY)
      top = __FILE__ +
      "top"
    RUBY
  end

  it 'registers offenses only for the appropriate lines in chained concats' do
    # only the last concatenation is an offense
    expect_offense(<<~'RUBY')
      top = "test#{x}" + # comment
      "foo" +
      %(bar) +
      "baz" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "qux"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" + # comment
      "foo" +
      %(bar) +
      "baz" \
      "qux"
    RUBY
  end

  # The "central autocorrection engine" can't handle intermediate states where
  # the code has syntax errors, so it's important to fix the trailing
  # whitespace in this cop.
  it 'autocorrects a + with trailing whitespace to \\' do
    expect_offense(<<~RUBY)
      top = "test" +#{trailing_whitespace}
                   ^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~RUBY)
      top = "test" \\
      "top"
    RUBY
  end

  it 'autocorrects a + with \\ to just \\' do
    expect_offense(<<~RUBY)
      top = "test" + \\
                   ^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY

    expect_correction(<<~RUBY)
      top = "test" \\
      "top"
    RUBY
  end

  it 'autocorrects only the lines that should be autocorrected' do
    expect_offense(<<~'RUBY')
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" + # comment
      "foo" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "bar" +
      %(baz) +
      "qux"
    RUBY

    expect_correction(<<~'RUBY')
      top = "test#{x}" \
      "top" + # comment
      "foo" \
      "bar" +
      %(baz) +
      "qux"
    RUBY
  end
end
