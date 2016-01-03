# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::StringLiteralsInInterpolation, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers an offense for double quotes within embedded expression' do
      src = '"#{"A"}"'
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['Prefer single-quoted strings inside interpolations.'])
    end

    it 'registers an offense for double quotes within embedded expression in ' \
       'a heredoc string' do
      src = ['<<END',
             '#{"A"}',
             'END']
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['Prefer single-quoted strings inside interpolations.'])
    end

    it 'accepts double quotes on a static string' do
      src = '"A"'
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes on a broken static string' do
      src = ['"A" \\',
             '  "B"']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes on static strings within a method' do
      src = ['def m',
             '  puts "A"',
             '  puts "B"',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
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
      new_source = autocorrect_source(cop, 's = "#{"abc"}"')
      expect(new_source).to eq(%q(s = "#{'abc'}"))
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers an offense for single quotes within embedded expression' do
      src = %q("#{'A'}")
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings inside interpolations.'])
    end

    it 'registers an offense for single quotes within embedded expression in ' \
       'a heredoc string' do
      src = ['<<END',
             '#{\'A\'}',
             'END']
      inspect_source(cop, src)
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings inside interpolations.'])
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source(cop, 'a = "#{"b"}"') }
        .to raise_error(RuntimeError)
    end
  end
end
