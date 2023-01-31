# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringLiterals, :config do
  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers offense for double quotes when single quotes suffice' do
      expect_offense(<<~'RUBY')
        s = "abc"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        x = "a\\b"
            ^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        y ="\\b"
           ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        z = "a\\"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        t = "{\"[\\\"*\\\"]\""
            ^^^^^^^^^^^^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'double_quotes')

      expect_correction(<<~'RUBY')
        s = 'abc'
        x = 'a\\b'
        y ='\\b'
        z = 'a\\'
        t = '{"[\"*\"]"'
      RUBY
    end

    it 'registers offense for correct + opposite' do
      expect_offense(<<~RUBY)
        s = "abc"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        x = 'abc'
      RUBY

      expect_correction(<<~RUBY)
        s = 'abc'
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
      expect_no_offenses(<<~RUBY)
        execute <<-SQL
          SELECT name from users
        SQL
      RUBY
    end

    it 'accepts double quotes when new line is used' do
      expect_no_offenses('"\n"')
    end

    it 'accepts double quotes when interpolating & quotes in multiple lines' do
      expect_no_offenses(<<~'RUBY')
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
      expect_no_offenses(<<~'RUBY')
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
      expect_offense(<<~'RUBY')
        "#{x}" \
        "y"
        ^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~'RUBY')
        "#{x}" \
        'y'
      RUBY
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<~RUBY)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it 'can handle character literals' do
      expect_no_offenses('a = ?/')
    end

    it 'registers an offense for "\""' do
      expect_offense(<<~'RUBY')
        "\""
        ^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~RUBY)
        '"'
      RUBY
    end

    it 'registers an offense for "\\"' do
      expect_offense(<<~'RUBY')
        "\\"
        ^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~'RUBY')
        '\\'
      RUBY
    end

    it 'registers an offense for words with non-ascii chars' do
      expect_offense(<<~RUBY)
        "España"
        ^^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~RUBY)
        'España'
      RUBY
    end

    it 'does not register an offense for words with non-ascii chars and other control sequences' do
      expect_no_offenses('"España\n"')
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers offense for single quotes when double quotes would be equivalent' do
      expect_offense(<<~RUBY)
        s = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'single_quotes')

      expect_correction(<<~RUBY)
        s = "abc"
      RUBY
    end

    it 'registers offense for opposite + correct' do
      expect_offense(<<~RUBY)
        s = "abc"
        x = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)

      expect_correction(<<~RUBY)
        s = "abc"
        x = "abc"
      RUBY
    end

    it 'registers offense for escaped single quote in single quotes' do
      expect_offense(<<~'RUBY')
        '\''
        ^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
        '\\'
        ^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~'RUBY')
        "'"
        "\\"
      RUBY
    end

    it 'does not accept multiple escaped single quotes in single quotes' do
      expect_offense(<<~'RUBY')
        'This \'string\' has \'multiple\' escaped quotes'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~RUBY)
        "This 'string' has 'multiple' escaped quotes"
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

    it 'accepts single quoted string with backslash' do
      expect_no_offenses(<<~'RUBY')
        '\,'
        '100\%'
        '(\)'
      RUBY
    end

    it 'accepts heredocs' do
      expect_no_offenses(<<~RUBY)
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
      expect_no_offenses(<<~'RUBY')
        a = '\n'
        b = '"'
        c = '#{x}'
        d = '#@x'
        e = '#$x'
        f = '\s'
        g = '\z'
      RUBY
    end

    it 'flags single quotes with plain # (not #@var or #{interpolation} or #$global' do
      expect_offense(<<~RUBY)
        a = 'blah #'
            ^^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~RUBY)
        a = "blah #"
      RUBY
    end

    it 'accepts single quotes at the start of regexp literals' do
      expect_no_offenses("s = /'((?:[^\\']|\\.)*)'/")
    end

    it "accepts ' in a %w" do
      expect_no_offenses("%w(')")
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<~RUBY)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { expect_no_offenses('a = "b"') }.to raise_error(RuntimeError)
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
        expect_offense(<<~RUBY)
          "--
          ^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          SELECT *
            LEFT JOIN X on Y
            FROM Models"
        RUBY

        expect_no_corrections
      end

      it 'accepts continued strings using all single quotes' do
        expect_no_offenses(<<~'RUBY')
          'abc' \
          'def'
        RUBY
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        expect_offense(<<~'RUBY')
          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for unneeded double quotes in continuation' do
        expect_offense(<<~'RUBY')
          "abc" \
          ^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          "def"
        RUBY

        expect_no_corrections
      end

      it "doesn't register offense for double quotes with interpolation" do
        expect_no_offenses(<<~'RUBY')
          "abc" \
          "def#{1}"
        RUBY
      end

      it "doesn't register offense for double quotes with embedded single" do
        expect_no_offenses(<<~'RUBY')
          "abc'" \
          "def"
        RUBY
      end

      it 'accepts for double quotes with an escaped special character' do
        expect_no_offenses(<<~'RUBY')
          "abc\t" \
          "def"
        RUBY
      end

      it 'accepts for double quotes with an escaped normal character' do
        expect_no_offenses(<<~'RUBY')
          "abc\!" \
          "def"
        RUBY
      end

      it "doesn't choke on heredocs with inconsistent indentation" do
        expect_no_offenses(<<~RUBY)
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
        expect_no_offenses(<<~'RUBY')
          "abc" \
          "def"
        RUBY
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        expect_offense(<<~'RUBY')
          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for unneeded single quotes in continuation' do
        expect_offense(<<~'RUBY')
          'abs' \
          ^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
          'def'
        RUBY

        expect_no_corrections
      end

      it "doesn't register offense for single quotes with embedded double" do
        expect_no_offenses(<<~'RUBY')
          'abc"' \
          'def'
        RUBY
      end
    end
  end
end
