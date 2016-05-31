# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

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
      inspect_source(cop, "a = 'x'")
      expect(cop.offenses).to be_empty
    end

    it 'accepts single quotes in interpolation' do
      inspect_source(cop, %q("hello#{hash['there']}"))
      expect(cop.offenses).to be_empty
    end

    it 'accepts %q and %Q quotes' do
      inspect_source(cop, 'a = %q(x) + %Q[x]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts % quotes' do
      inspect_source(cop, 'a = %(x)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts heredocs' do
      inspect_source(cop,
                     ['execute <<-SQL',
                      '  SELECT name from users',
                      'SQL'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes when they are needed' do
      src = ['a = "\n"',
             'b = "#{encode_severity}:' \
             '#{sprintf(\'%3d\', line_number)}: #{m}"',
             'c = "\'"',
             'd = "#@test"',
             'e = "#$test"',
             'f = "\e"',
             'g = "#@@test"']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes at the start of regexp literals' do
      inspect_source(cop, 's = /"((?:[^\\"]|\\.)*)"/')
      expect(cop.offenses).to be_empty
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
      inspect_source(cop, '%w(")')
      expect(cop.offenses).to be_empty
    end

    it 'accepts \\\\\n in a string' do # this would be: "\\\n"
      inspect_source(cop, '"foo \\\\\n bar"')
      expect(cop.offenses).to be_empty
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

    it 'registers an offense for hello... using hex escapes' do
      inspect_source(cop, '"\\x68\\x65\\x6c\\x6c\\x6f"')
      expect(cop.offenses.size).to eq(1)
    end

    it 'autocorrects hello... using hex escapes' do
      new_source = autocorrect_source(cop, '"\\x68\\x65\\x6c\\x6c\\x6f"')
      expect(new_source).to eq("'hello'")
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
      inspect_source(cop, 'a = "x"')
      expect(cop.offenses).to be_empty
    end

    it 'accepts single quotes in interpolation' do
      inspect_source(cop, %q("hello#{hash['there']}"))
      expect(cop.offenses).to be_empty
    end

    it 'accepts %q and %Q quotes' do
      inspect_source(cop, 'a = %q(x) + %Q[x]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts % quotes' do
      inspect_source(cop, 'a = %(x)')
      expect(cop.offenses).to be_empty
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
      inspect_source(cop, "s = /'((?:[^\\']|\\.)*)'/")
      expect(cop.offenses).to be_empty
    end

    it "accepts ' in a %w" do
      inspect_source(cop, "%w(')")
      expect(cop.offenses).to be_empty
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

      it 'does not crash on strings with line breaks in them' do
        inspect_source(cop,
                       ['"--',
                        'SELECT *',
                        'LEFT JOIN X on Y',
                        'FROM Models"'])
        # TODO: We should actually get an offense report here telling us to use
        # single quotes. For now, we only check that we don't crash.
        expect(cop.offenses).to be_empty
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
