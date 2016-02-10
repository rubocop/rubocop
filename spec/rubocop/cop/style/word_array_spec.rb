# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::WordArray, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is percent' do
    let(:cop_config) do
      { 'MinSize' => 0,
        'WordRegex' => /\A[\p{Word}\n\t]+\z/,
        'EnforcedStyle' => 'percent' }
    end

    it 'registers an offense for arrays of single quoted strings' do
      inspect_source(cop, "['one', 'two', 'three']")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%w` or `%W` for an array of words.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'brackets')
    end

    it 'registers an offense for arrays of double quoted strings' do
      inspect_source(cop, '["one", "two", "three"]')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for arrays of unicode word characters' do
      inspect_source(cop, '["ВУЗ", "вуз", "中文网"]')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for arrays with character constants' do
      inspect_source(cop, '["one", ?\n]')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for strings with embedded newlines and tabs' do
      inspect_source(cop, %(["one\n", "hi\tthere"]))
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for strings with newline and tab escapes' do
      inspect_source(cop, %(["one\\n", "hi\\tthere"]))
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for word arrays with double quotes' do
      inspect_source(cop, '%w("one", "two")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for word arrays with single quotes' do
      inspect_source(cop, "%w('one', 'two')")
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for word arrays with commas' do
      inspect_source(cop, '%w(one, two)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not register an offense for array with commas' do
      inspect_source(cop, '["one,", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array with quotes' do
      inspect_source(cop, '["one\'", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array with double quotes' do
      inspect_source(cop, '["one\"", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'uses %W when autocorrecting strings with newlines and tabs' do
      new_source = autocorrect_source(cop, %(["one\\n", "hi\\tthere"]))
      expect(new_source).to eq('%W(one\\n hi\\tthere)')
    end

    it 'does not register an offense for array of non-words' do
      inspect_source(cop, '["one space", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array containing non-string' do
      inspect_source(cop, '["one", "two", 3]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array starting with %w' do
      inspect_source(cop, '%w(one two three)')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array with one element' do
      inspect_source(cop, '["three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for array with empty strings' do
      inspect_source(cop, '["", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register offense for array with allowed number of strings' do
      cop_config['MinSize'] = 4
      inspect_source(cop, '["one", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for an array with comments in it' do
      inspect_source(cop,
                     ['[',
                      '"foo", # comment here',
                      '"bar", # this thing was done because of a bug',
                      '"baz" # do not delete this line',
                      ']'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for an array with comments outside of it' do
      inspect_source(cop,
                     ['[',
                      '"foo",',
                      '"bar",',
                      '"baz"',
                      '] # test'])

      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects an array of words' do
      new_source = autocorrect_source(cop, "['one', %q(two), 'three']")
      expect(new_source).to eq('%w(one two three)')
    end

    it 'auto-corrects an array of words and character constants' do
      new_source = autocorrect_source(cop, '[%{one}, %Q(two), ?\n, ?\t]')
      expect(new_source).to eq('%W(one two \n \t)')
    end

    it 'keeps the line breaks in place after auto-correct' do
      new_source = autocorrect_source(cop,
                                      ["['one',",
                                       "'two', 'three']"])
      expect(new_source).to eq(['%w(one ',
                                'two three)'].join("\n"))
    end

    it 'detects right value of MinSize to use for --auto-gen-config' do
      inspect_source(cop,
                     ["['one', 'two', 'three']",
                      '%w(a b c d)'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%w` or `%W` for an array of words.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent',
                                                 'MinSize' => 4)
    end

    it 'detects when the cop must be disabled to avoid offenses' do
      inspect_source(cop,
                     ["['one', 'two', 'three']",
                      '%w(a b)'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%w` or `%W` for an array of words.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when EnforcedStyle is array' do
    let(:cop_config) do
      { 'MinSize' => 0,
        'WordRegex' => /\A[\p{Word}]+\z/,
        'EnforcedStyle' => 'brackets' }
    end

    it 'does not register an offense for arrays of single quoted strings' do
      inspect_source(cop, "['one', 'two', 'three']")
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for arrays of double quoted strings' do
      inspect_source(cop, '["one", "two", "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a %w() array' do
      inspect_source(cop, '%w(one two three)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects a %w() array' do
      new_source = autocorrect_source(cop, '%w(one two three)')
      expect(new_source).to eq("['one', 'two', 'three']")
    end

    it 'autocorrects a %w() array which uses single quotes' do
      new_source = autocorrect_source(cop, "%w(one's two's three's)")
      expect(new_source).to eq('["one\'s", "two\'s", "three\'s"]')
    end

    it 'autocorrects a %W() array which uses escapes' do
      new_source = autocorrect_source(cop, '%W(\\n \\t \\b \\v \\f)')
      expect(new_source).to eq('["\n", "\t", "\b", "\v", "\f"]')
    end

    it "doesn't fail on strings which are not valid UTF-8" do
      # Regression test, see GH issue 2671
      inspect_source(cop, ['["\xC0",',
                           ' "\xC2\x4a",',
                           ' "\xC2\xC2",',
                           ' "\x4a\x82",',
                           ' "\x82\x82",',
                           ' "\xe1\x82\x4a",',
                           ']'])
      # Currently, this cop completely ignores strings with invalid encoding
      # If it could handle them and still report an offense when appropriate,
      # that would be even better
      expect(cop.offenses).to be_empty
    end
  end

  context 'with a custom WordRegex configuration' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\A[\w@.]+\z/ } }

    it 'registers an offense for arrays of email addresses' do
      inspect_source(cop, "['a@example.com', 'b@example.com']")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects an array of email addresses' do
      new_source = autocorrect_source(cop, "['a@example.com', 'b@example.com']")
      expect(new_source).to eq('%w(a@example.com b@example.com)')
    end
  end

  context 'with a WordRegex configuration which accepts almost anything' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\S+/ } }

    it 'uses %W when autocorrecting strings with non-printable chars' do
      new_source = autocorrect_source(cop, '["\x1f\x1e", "hello"]')
      expect(new_source).to eq('%W(\u001F\u001E hello)')
    end

    it 'uses %w for strings which only appear to have an escape' do
      new_source = autocorrect_source(cop, "['hi\\tthere', 'again\\n']")
      expect(new_source).to eq('%w(hi\\tthere again\\n)')
    end
  end

  context 'with a treacherous WordRegex configuration' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /[\w \[\]\(\)]/ } }

    it "doesn't break when words contain whitespace" do
      new_source = autocorrect_source(cop, "['hi there', 'something\telse']")
      expect(new_source).to eq("['hi there', 'something\telse']")
    end

    it "doesn't break when words contain delimiters" do
      new_source = autocorrect_source(cop, "[')', ']']")
      expect(new_source).to eq('%w(\\) ])')
    end
  end
end
