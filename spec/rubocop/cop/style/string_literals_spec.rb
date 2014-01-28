# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::StringLiterals, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers offence for double quotes when single quotes ' \
      'suffice' do
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
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                 'double_quotes')
    end

    it 'registers offence for correct + opposite' do
      inspect_source(cop, ['s = "abc"',
                           "x = 'abc'"])
      expect(cop.messages)
        .to eq(["Prefer single-quoted strings when you don't need " \
                'string interpolation or special symbols.'])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'accepts single quotes' do
      inspect_source(cop, ["a = 'x'"])
      expect(cop.offences).to be_empty
    end

    it 'accepts %q and %Q quotes' do
      inspect_source(cop, ['a = %q(x) + %Q[x]'])
      expect(cop.offences).to be_empty
    end

    it 'accepts % quotes' do
      inspect_source(cop, ['a = %(x)'])
      expect(cop.offences).to be_empty
    end

    it 'accepts heredocs' do
      inspect_source(cop,
                     ['execute <<-SQL',
                      '  SELECT name from users',
                      'SQL'])

      expect(cop.offences).to be_empty
    end

    it 'accepts double quotes when they are needed' do
      src = ['a = "\n"',
             'b = "#{encode_severity}:' \
             '#{sprintf("%3d", line_number)}: #{m}"',
             'c = "\'"',
             'd = "#@test"',
             'e = "#$test"',
             'f = "\e"',
             'g = "#@@test"']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'accepts double quotes at the start of regexp literals' do
      inspect_source(cop, ['s = /"((?:[^\\"]|\\.)*)"/'])
      expect(cop.offences).to be_empty
    end

    it 'accepts double quotes with some other special symbols' do
      # "Substitutions in double-quoted strings"
      # http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html
      src = ['g = "\xf9"',
             'copyright = "\u00A9"']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'accepts " in a %w' do
      inspect_source(cop, ['%w(")'])
      expect(cop.offences).to be_empty
    end

    it 'accepts \\\\\n in a string' do # this would be: "\\\n"
      inspect_source(cop, ['"foo \\\\\n bar"'])
      expect(cop.offences).to be_empty
    end

    it 'can handle double quotes within embedded expression' do
      src = ['"#{"A"}"']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      src = ['if __FILE__ == $PROGRAM_NAME',
             'end']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'can handle character literals' do
      src = 'a = ?/'
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'auto-corrects " with \'' do
      new_source = autocorrect_source(cop, 's = "abc"')
      expect(new_source).to eq("s = 'abc'")
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers offence for single quotes when double quotes would ' \
      'be equivalent' do
      inspect_source(cop, ["s = 'abc'"])
      expect(cop.highlights).to eq(["'abc'"])
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings unless you need ' \
                'single quotes to avoid extra backslashes for ' +
                'escaping.'])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                 'single_quotes')
    end

    it 'registers offence for opposite + correct' do
      inspect_source(cop, ['s = "abc"',
                           "x = 'abc'"])
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings unless you need ' \
                'single quotes to avoid extra backslashes for ' +
                'escaping.'])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'accepts double quotes' do
      inspect_source(cop, ['a = "x"'])
      expect(cop.offences).to be_empty
    end

    it 'accepts %q and %Q quotes' do
      inspect_source(cop, ['a = %q(x) + %Q[x]'])
      expect(cop.offences).to be_empty
    end

    it 'accepts % quotes' do
      inspect_source(cop, ['a = %(x)'])
      expect(cop.offences).to be_empty
    end

    it 'accepts heredocs' do
      inspect_source(cop,
                     ['execute <<-SQL',
                      '  SELECT name from users',
                      'SQL'])

      expect(cop.offences).to be_empty
    end

    it 'accepts single quotes when they are needed' do
      src = ["a = '\\n'",
             "b = '\"'"]
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'accepts single quotes at the start of regexp literals' do
      inspect_source(cop, ["s = /'((?:[^\\']|\\.)*)'/"])
      expect(cop.offences).to be_empty
    end

    it "accepts ' in a %w" do
      inspect_source(cop, ["%w(')"])
      expect(cop.offences).to be_empty
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      src = ['if __FILE__ == $PROGRAM_NAME',
             'end']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it "auto-corrects ' with \"" do
      new_source = autocorrect_source(cop, "s = 'abc'")
      expect(new_source).to eq('s = "abc"')
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source(cop, ['a = "b"']) }
        .to raise_error(RuntimeError)
    end
  end
end
