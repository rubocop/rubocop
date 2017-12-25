# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringLiterals, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers offense for double quotes when single quotes suffice' do
      inspect_source(['s = "abc"',
                      'x = "a\\\\b"',
                      'y ="\\\\b"',
                      'z = "a\\\\"'])
      expect(cop.highlights).to eq(['"abc"',
                                    '"a\\\\b"',
                                    '"\\\\b"',
                                    '"a\\\\"'])
      expect(cop.messages)
        .to eq(["Prefer single-quoted strings when you don't need " \
                'string interpolation or special symbols.'] * 4)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'double_quotes')
    end

    it 'registers offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        s = "abc"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        x = 'abc'
      RUBY
    end

    it 'accepts single quotes' do
      expect_no_offenses("a = 'x'")
    end

    it 'accepts single quotes in interpolation' do
      expect_no_offenses(%q("hello#{hash['there']}"))
    end

    it 'accepts %q and %Q quotes' do
      expect_no_offenses('a = %q(x) + %Q[x]')
    end

    it 'accepts % quotes' do
      expect_no_offenses('a = %(x)')
    end

    it 'accepts heredocs' do
      expect_no_offenses(<<-RUBY.strip_indent)
        execute <<-SQL
          SELECT name from users
        SQL
      RUBY
    end

    it 'accepts double quotes when new line is used' do
      expect_no_offenses('"\n"')
    end

    it 'accepts double quotes when interpolating & quotes in multiple lines' do
      expect_no_offenses(<<-'RUBY'.strip_indent)
        "#{encode_severity}:#{sprintf('%3d', line_number)}: #{m}"
      RUBY
    end

    it 'accepts double quotes when single quotes are used' do
      expect_no_offenses('"\'"')
    end

    it 'accepts double quotes when interpolating an instance variable' do
      expect_no_offenses('"#@test"')
    end

    it 'accepts double quotes when interpolating a global variable' do
      expect_no_offenses('"#$test"')
    end

    it 'accepts double quotes when interpolating a class variable' do
      expect_no_offenses('"#@@test"')
    end

    it 'accepts double quotes when control characters are used' do
      expect_no_offenses('"\e"')
    end

    it 'accepts double quotes when unicode control sequence is used' do
      expect_no_offenses('"Espa\u00f1a"')
    end

    it 'accepts double quotes at the start of regexp literals' do
      expect_no_offenses('s = /"((?:[^\\"]|\\.)*)"/')
    end

    it 'accepts double quotes with some other special symbols' do
      # "Substitutions in double-quoted strings"
      # http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html
      expect_no_offenses(<<-'RUBY'.strip_indent)
        g = "\xf9"
        copyright = "\u00A9"
      RUBY
    end

    it 'accepts " in a %w' do
      expect_no_offenses('%w(")')
    end

    it 'accepts \\\\\n in a string' do # this would be: "\\\n"
      expect_no_offenses('"foo \\\\\n bar"')
    end

    it 'accepts double quotes in interpolation' do
      expect_no_offenses("\"\#{\"A\"}\"")
    end

    it 'detects unneeded double quotes within concatenated string' do
      src = ['"#{x}" \\', '"y"']
      inspect_source(src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<-RUBY.strip_indent)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it 'can handle character literals' do
      expect_no_offenses('a = ?/')
    end

    it 'auto-corrects " with \'' do
      new_source = autocorrect_source('s = "abc"')
      expect(new_source).to eq("s = 'abc'")
    end

    it 'registers an offense for "\""' do
      expect_offense(<<-'RUBY'.strip_indent)
        "\""
        ^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY
    end

    it 'registers an offense for words with non-ascii chars' do
      expect_offense(<<-RUBY.strip_indent)
        "España"
        ^^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY
    end

    it 'autocorrects words with non-ascii chars' do
      new_source = autocorrect_source('"España"')
      expect(new_source).to eq("'España'")
    end

    it 'does not register an offense for words with non-ascii chars and ' \
       'other control sequences' do
      inspect_source('"España\n"')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not autocorrect words with non-ascii chars and other control ' \
       'sequences' do
      new_source = autocorrect_source('"España\n"')
      expect(new_source).to eq('"España\n"')
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers offense for single quotes when double quotes would ' \
      'be equivalent' do
      expect_offense(<<-RUBY.strip_indent)
        s = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'single_quotes')
    end

    it 'registers offense for opposite + correct' do
      expect_offense(<<-'RUBY'.strip_indent)
        s = "abc"
        x = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers offense for escaped single quote in single quotes' do
      expect_offense(<<-'RUBY'.strip_indent)
        '\''
        ^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
    end

    it 'does not accept multiple escaped single quotes in single quotes' do
      expect_offense(<<-'RUBY'.strip_indent)
        'This \'string\' has \'multiple\' escaped quotes'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
    end

    it 'accepts double quotes' do
      expect_no_offenses('a = "x"')
    end

    it 'accepts single quotes in interpolation' do
      expect_no_offenses(%q("hello#{hash['there']}"))
    end

    it 'accepts %q and %Q quotes' do
      expect_no_offenses('a = %q(x) + %Q[x]')
    end

    it 'accepts % quotes' do
      expect_no_offenses('a = %(x)')
    end

    it 'accepts heredocs' do
      expect_no_offenses(<<-RUBY.strip_indent)
        execute <<-SQL
          SELECT name from users
        SQL
      RUBY
    end

    it 'accepts single quotes in string with escaped non-\' character' do
      expect_no_offenses(%q('\n'))
    end

    it 'accepts escaped single quote in string with escaped non-\' character' do
      expect_no_offenses(%q('\'\n'))
    end

    it 'accepts single quotes when they are needed' do
      expect_no_offenses(<<-'RUBY'.strip_indent)
        a = '\n'
        b = '"'
        c = '#{x}'
      RUBY
    end

    it 'flags single quotes with plain # (not #@var or #{interpolation}' do
      inspect_source("a = 'blah #'")
      expect(cop.offenses.size).to be 1
    end

    it 'accepts single quotes at the start of regexp literals' do
      expect_no_offenses("s = /'((?:[^\\']|\\.)*)'/")
    end

    it "accepts ' in a %w" do
      expect_no_offenses("%w(')")
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<-RUBY.strip_indent)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it "auto-corrects ' with \"" do
      new_source = autocorrect_source("s = 'abc'")
      expect(new_source).to eq('s = "abc"')
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source('a = "b"') }
        .to raise_error(RuntimeError)
    end
  end

  context 'when ConsistentQuotesInMultiline is true' do
    context 'and EnforcedStyle is single_quotes' do
      let(:cop_config) do
        {
          'ConsistentQuotesInMultiline' => true,
          'EnforcedStyle' => 'single_quotes'
        }
      end

      it 'registers an offense for strings with line breaks in them' do
        expect_offense(<<-'RUBY'.strip_indent)
          "--
          ^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          SELECT *
            LEFT JOIN X on Y
            FROM Models"
        RUBY
      end

      it 'accepts continued strings using all single quotes' do
        expect_no_offenses(<<-RUBY.strip_indent)
          'abc' \
          'def'
        RUBY
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        expect_offense(<<-'RUBY'.strip_indent)
          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
        RUBY
      end

      it 'registers an offense for unneeded double quotes in continuation' do
        expect_offense(<<-'RUBY'.strip_indent)
          "abc" \
          ^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          "def"
        RUBY
      end

      it "doesn't register offense for double quotes with interpolation" do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          "abc" \
          "def#{1}"
        RUBY
      end

      it "doesn't register offense for double quotes with embedded single" do
        expect_no_offenses(<<-RUBY.strip_indent)
          "abc'" \
          "def"
        RUBY
      end

      it 'accepts for double quotes with an escaped special character' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          "abc\t" \
          "def"
        RUBY
      end

      it 'accepts for double quotes with an escaped normal character' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          "abc\!" \
          "def"
        RUBY
      end

      it "doesn't choke on heredocs with inconsistent indentation" do
        expect_no_offenses(<<-RUBY.strip_indent)
          <<-QUERY_STRING
            DEFINE
              BLAH
          QUERY_STRING
        RUBY
      end
    end

    context 'and EnforcedStyle is double_quotes' do
      let(:cop_config) do
        {
          'ConsistentQuotesInMultiline' => true,
          'EnforcedStyle' => 'double_quotes'
        }
      end

      it 'accepts continued strings using all double quotes' do
        expect_no_offenses(<<-RUBY.strip_indent)
          "abc" \
          "def"
        RUBY
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        expect_offense(<<-'RUBY'.strip_indent)
          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
        RUBY
      end

      it 'registers an offense for unneeded single quotes in continuation' do
        expect_offense(<<-'RUBY'.strip_indent)
          'abs' \
          ^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
          'def'
        RUBY
      end

      it "doesn't register offense for single quotes with embedded double" do
        expect_no_offenses(<<-RUBY.strip_indent)
          'abc"' \
          'def'
        RUBY
      end
    end
  end
end
