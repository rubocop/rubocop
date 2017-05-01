# frozen_string_literal: true

describe RuboCop::Cop::Style::StringLiterals, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers offense for double quotes when single quotes suffice' do
      inspect_source(cop, ['s = "abc"',
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
      inspect_source(cop, ['s = "abc"',
                           "x = 'abc'"])
      expect(cop.messages)
        .to eq(["Prefer single-quoted strings when you don't need " \
                'string interpolation or special symbols.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
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
      inspect_source(cop,
                     ['execute <<-SQL',
                      '  SELECT name from users',
                      'SQL'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes when new line is used' do
      expect_no_offenses('"\n"')
    end

    it 'accepts double quotes when interpolating & quotes in multiple lines' do
      inspect_source(cop, '"#{encode_severity}:' \
                          '#{sprintf(\'%3d\', line_number)}: #{m}"')
      expect(cop.offenses).to be_empty
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
      src = ['g = "\xf9"',
             'copyright = "\u00A9"']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts " in a %w' do
      expect_no_offenses('%w(")')
    end

    it 'accepts \\\\\n in a string' do # this would be: "\\\n"
      expect_no_offenses('"foo \\\\\n bar"')
    end

    it 'accepts double quotes in interpolation' do
      src = '"#{"A"}"'
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'detects unneeded double quotes within concatenated string' do
      src = ['"#{x}" \\', '"y"']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      src = ['if __FILE__ == $PROGRAM_NAME',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'can handle character literals' do
      src = 'a = ?/'
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects " with \'' do
      new_source = autocorrect_source(cop, 's = "abc"')
      expect(new_source).to eq("s = 'abc'")
    end

    it 'registers an offense for "\""' do
      inspect_source(cop, '"\\""')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Prefer single-quoted strings when you ' \
                                  "don't need string interpolation or " \
                                  'special symbols.'])
    end

    it 'registers an offense for words with non-ascii chars' do
      inspect_source(cop, '"España"')
      expect(cop.offenses.size).to eq(1)
    end

    it 'autocorrects words with non-ascii chars' do
      new_source = autocorrect_source(cop, '"España"')
      expect(new_source).to eq("'España'")
    end

    it 'does not register an offense for words with non-ascii chars and ' \
       'other control sequences' do
      inspect_source(cop, '"España\n"')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not autocorrect words with non-ascii chars and other control ' \
       'sequences' do
      new_source = autocorrect_source(cop, '"España\n"')
      expect(new_source).to eq('"España\n"')
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers offense for single quotes when double quotes would ' \
      'be equivalent' do
      inspect_source(cop, "s = 'abc'")
      expect(cop.highlights).to eq(["'abc'"])
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings unless you need ' \
                'single quotes to avoid extra backslashes for ' \
                'escaping.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'single_quotes')
    end

    it 'registers offense for opposite + correct' do
      inspect_source(cop, ['s = "abc"',
                           "x = 'abc'"])
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings unless you need ' \
                'single quotes to avoid extra backslashes for ' \
                'escaping.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
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
      inspect_source(cop,
                     ['execute <<-SQL',
                      '  SELECT name from users',
                      'SQL'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts single quotes when they are needed' do
      src = ["a = '\\n'",
             "b = '\"'",
             "c = '\#{x}'"]
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'flags single quotes with plain # (not #@var or #{interpolation}' do
      inspect_source(cop, "a = 'blah #'")
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
      src = ['if __FILE__ == $PROGRAM_NAME',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it "auto-corrects ' with \"" do
      new_source = autocorrect_source(cop, "s = 'abc'")
      expect(new_source).to eq('s = "abc"')
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source(cop, 'a = "b"') }
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
        inspect_source(cop,
                       ['"--',
                        'SELECT *',
                        'LEFT JOIN X on Y',
                        'FROM Models"'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(['Prefer single-quoted strings when you ' \
                                    "don't need string interpolation or " \
                                    'special symbols.'])
      end

      it 'accepts continued strings using all single quotes' do
        inspect_source(cop, ["'abc' \\",
                             "'def'"])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        inspect_source(cop, ["'abc' \\",
                             '"def"'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(['Inconsistent quote style.'])
        expect(cop.highlights).to eq(["'abc' \\\n\"def\""])
      end

      it 'registers an offense for unneeded double quotes in continuation' do
        inspect_source(cop, ['"abc" \\',
                             '"def"'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(['Prefer single-quoted strings when you ' \
                                    "don't need string interpolation or " \
                                    'special symbols.'])
        expect(cop.highlights).to eq(["\"abc\" \\\n\"def\""])
      end

      it "doesn't register offense for double quotes with interpolation" do
        inspect_source(cop, ['"abc" \\',
                             '"def#{1}"'])
        expect(cop.offenses).to be_empty
      end

      it "doesn't register offense for double quotes with embedded single" do
        inspect_source(cop, ['"abc\'" \\',
                             '"def"'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts for double quotes with an escaped special character' do
        inspect_source(cop, ['"abc\\t" \\',
                             '"def"'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts for double quotes with an escaped normal character' do
        inspect_source(cop, ['"abc\\!" \\',
                             '"def"'])
        expect(cop.offenses).to be_empty
      end

      it "doesn't choke on heredocs with inconsistent indentation" do
        inspect_source(cop, ['<<-QUERY_STRING',
                             '  DEFINE',
                             '    BLAH',
                             'QUERY_STRING'])
        expect(cop.offenses).to be_empty
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
        inspect_source(cop, ['"abc" \\',
                             '"def"'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for mixed quote styles in a continued string' do
        inspect_source(cop, ["'abc' \\",
                             '"def"'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(['Inconsistent quote style.'])
        expect(cop.highlights).to eq(["'abc' \\\n\"def\""])
      end

      it 'registers an offense for unneeded single quotes in continuation' do
        inspect_source(cop, ["'abc' \\",
                             "'def'"])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(['Prefer double-quoted strings unless you ' \
                                    'need single quotes to avoid extra ' \
                                    'backslashes for escaping.'])
        expect(cop.highlights).to eq(["'abc' \\\n'def'"])
      end

      it "doesn't register offense for single quotes with embedded double" do
        inspect_source(cop, ["'abc\"' \\",
                             "'def'"])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
