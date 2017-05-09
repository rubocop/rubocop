# frozen_string_literal: true

describe RuboCop::Cop::Style::UnneededPercentQ do
  subject(:cop) { described_class.new }

  context 'with %q strings' do
    it 'registers an offense for only single quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q('hi')
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'registers an offense for only double quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q("hi")
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'registers an offense for no quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %q(hi)
        ^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      inspect_source(cop, %q(%q('"hi"')))

      expect(cop.messages).to be_empty
    end

    it 'registers an offfense for a string containing escaped backslashes' do
      inspect_source(cop, '%q(\\\\foo\\\\)')

      expect(cop.messages.length).to eq 1
    end

    it 'accepts a string with escaped non-backslash characters' do
      inspect_source(cop, "%q(\\'foo\\')")

      expect(cop.messages).to be_empty
    end

    it 'accepts a string with escaped backslash and non-backslash characters' do
      inspect_source(cop, "%q(\\\\ \\'foo\\' \\\\)") # This is \\ \'foo\' \\

      expect(cop.messages).to be_empty
    end

    it 'accepts regular expressions starting with %q' do
      inspect_source(cop, '/%q?/')

      expect(cop.messages).to be_empty
    end

    context 'auto-correct' do
      it 'registers an offense for only single quotes' do
        new_source = autocorrect_source(cop, "%q('hi')")

        expect(new_source).to eq(%q("'hi'"))
      end

      it 'registers an offense for only double quotes' do
        new_source = autocorrect_source(cop, '%q("hi")')

        expect(new_source).to eq(%q('"hi"'))
      end

      it 'registers an offense for no quotes' do
        new_source = autocorrect_source(cop, '%q(hi)')

        expect(new_source).to eq("'hi'")
      end
    end
  end

  context 'with %Q strings' do
    it 'registers an offense for static string without quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %Q(hi)
        ^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'registers an offense for static string with only double quotes' do
      expect_offense(<<-RUBY.strip_indent)
        %Q("hi")
        ^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'registers an offense for dynamic string without quotes' do
      expect_offense(<<-'RUBY'.strip_indent)
        %Q(hi#{4})
        ^^^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
      RUBY
    end

    it 'accepts a string with single quotes and double quotes' do
      inspect_source(cop, %q(%Q('"hi"')))

      expect(cop.messages).to be_empty
    end

    it 'accepts a string with double quotes and an escaped special character' do
      inspect_source(cop, '%Q("\\thi")')

      expect(cop.messages).to be_empty
    end

    it 'accepts a string with double quotes and an escaped normal character' do
      inspect_source(cop, '%Q("\\!thi")')

      expect(cop.messages).to be_empty
    end

    it 'accepts a dynamic %Q string with double quotes' do
      inspect_source(cop, '%Q("hi#{4}")')

      expect(cop.messages).to be_empty
    end

    it 'accepts regular expressions starting with %Q' do
      inspect_source(cop, '/%Q?/')

      expect(cop.messages).to be_empty
    end

    context 'auto-correct' do
      it 'corrects a static string without quotes' do
        new_source = autocorrect_source(cop, '%Q(hi)')

        expect(new_source).to eq('"hi"')
      end

      it 'corrects a static string with only double quotes' do
        new_source = autocorrect_source(cop, '%Q("hi")')

        expect(new_source).to eq(%q('"hi"'))
      end

      it 'corrects a dynamic string without quotes' do
        new_source = autocorrect_source(cop, "%Q(hi\#{4})")

        expect(new_source).to eq(%("hi\#{4}"))
      end
    end
  end

  it 'accepts a heredoc string that contains %q' do
    inspect_source(cop, ['  s = <<END',
                         "%q('hi') # line 1",
                         '%q("hi")',
                         'END'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts %q at the beginning of a double quoted string ' \
     'with interpolation' do
    inspect_source(cop, "\"%q(a)\#{b}\"")

    expect(cop.messages).to be_empty
  end

  it 'accepts %Q at the beginning of a double quoted string ' \
     'with interpolation' do
    inspect_source(cop, "\"%Q(a)\#{b}\"")

    expect(cop.messages).to be_empty
  end

  it 'accepts %q at the beginning of a section of a double quoted string ' \
     'with interpolation' do
    inspect_source(cop, %("%\#{b}%q(a)"))

    expect(cop.messages).to be_empty
  end

  it 'accepts %Q at the beginning of a section of a double quoted string ' \
     'with interpolation' do
    inspect_source(cop, %("%\#{b}%Q(a)"))

    expect(cop.messages).to be_empty
  end

  it 'accepts %q containing string interpolation' do
    inspect_source(cop, %(%q(foo \#{'bar'} baz)))

    expect(cop.messages).to be_empty
  end
end
