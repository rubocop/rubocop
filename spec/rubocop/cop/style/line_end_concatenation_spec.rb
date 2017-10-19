# frozen_string_literal: true

describe RuboCop::Cop::Style::LineEndConcatenation do
  subject(:cop) { described_class.new }

  it 'registers an offense for string concat at line end' do
    expect_offense(<<-RUBY.strip_indent)
      top = "test" +
                   ^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY
  end

  it 'registers an offense for string concat with << at line end' do
    expect_offense(<<-RUBY.strip_indent)
      top = "test" <<
                   ^^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY
  end

  it 'registers an offense for string concat with << and \ at line ends' do
    expect_offense(<<-RUBY.strip_indent)
      top = "test " \\
      "foo" <<
            ^^ Use `\\` instead of `+` or `<<` to concatenate those strings.
      "bar"
    RUBY
  end

  it 'registers an offense for dynamic string concat at line end' do
    expect_offense(<<-'RUBY'.strip_indent)
      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY
  end

  it 'registers an offense for dynamic string concat with << at line end' do
    expect_offense(<<-'RUBY'.strip_indent)
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
    RUBY
  end

  it 'registers multiple offenses when there are chained << methods' do
    expect_offense(<<-'RUBY'.strip_indent)
      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" <<
            ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "ubertop"
    RUBY
  end

  it 'registers multiple offenses when there are chained concatenations' do
    expect_offense(<<-'RUBY'.strip_indent)
      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "foo"
    RUBY
  end

  it 'registers multiple offenses when there are chained concatenations' \
     'combined with << calls' do
    inspect_source(['top = "test#{x}" <<',
                    '"top" +',
                    '"foo" <<',
                    '"bar"'])
    expect(cop.offenses.size).to eq(3)
  end

  it 'accepts string concat on the same line' do
    expect_no_offenses('top = "test" + "top"')
  end

  it 'accepts string concat with a return value of method on a string' do
    expect_no_offenses(<<-RUBY.strip_indent)
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

  it 'accepts string concat with a return value of method on an interpolated ' \
     'string' do
    source = <<-RUBY
      x3a = 'x' +
        "\#{'a' + "\#{3}"}".reverse
    RUBY
    inspect_source(source)
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts string concat at line end when followed by comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      top = "test" + # something
      "top"
    RUBY
  end

  it 'accepts string concat at line end when followed by a comment line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      top = "test" +
      # something
      "top"
    RUBY
  end

  it 'accepts string concat at line end when % literals are involved' do
    expect_no_offenses(<<-RUBY.strip_indent)
      top = %(test) +
      "top"
    RUBY
  end

  it 'accepts string concat at line end for special strings like __FILE__' do
    expect_no_offenses(<<-RUBY.strip_indent)
      top = __FILE__ +
      "top"
    RUBY
  end

  it 'registers offenses only for the appropriate lines in chained concats' do
    # only the last concatenation is an offense
    expect_offense(<<-'RUBY'.strip_indent)
      top = "test#{x}" + # comment
      "foo" +
      %(bar) +
      "baz" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "qux"
    RUBY
  end

  it 'autocorrects in the simple case by replacing + with \\' do
    corrected = autocorrect_source(['top = "test" +',
                                    '"top"'])
    expect(corrected).to eq ['top = "test" \\', '"top"'].join("\n")
  end

  # The "central auto-correction engine" can't handle intermediate states where
  # the code has syntax errors, so it's important to fix the trailing
  # whitespace in this cop.
  it 'autocorrects a + with trailing whitespace to \\' do
    corrected = autocorrect_source(['top = "test" + ',
                                    '"top"'])
    expect(corrected).to eq ['top = "test" \\', '"top"'].join("\n")
  end

  it 'autocorrects a + with \\ to just \\' do
    corrected = autocorrect_source(['top = "test" + \\',
                                    '"top"'])
    expect(corrected).to eq ['top = "test" \\', '"top"'].join("\n")
  end

  it 'autocorrects for chained concatenations and << calls' do
    corrected = autocorrect_source(['top = "test#{x}" <<',
                                    '"top" +',
                                    '"ubertop" <<',
                                    '"foo"'])

    expect(corrected).to eq ['top = "test#{x}" \\',
                             '"top" \\',
                             '"ubertop" \\',
                             '"foo"'].join("\n")
  end

  it 'autocorrects only the lines that should be autocorrected' do
    corrected = autocorrect_source(['top = "test#{x}" <<',
                                    '"top" + # comment',
                                    '"foo" +',
                                    '"bar" +',
                                    '%(baz) +',
                                    '"qux"'])

    expect(corrected).to eq ['top = "test#{x}" \\',
                             '"top" + # comment',
                             '"foo" \\',
                             '"bar" +',
                             '%(baz) +',
                             '"qux"'].join("\n")
  end
end
