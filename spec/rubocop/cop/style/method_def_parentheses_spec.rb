# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MethodDefParentheses, :config do
  subject(:cop) { described_class.new(config) }

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it 'reports an offence for def with parameters but no parens' do
      src = ['def func a, b',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                 'require_no_parentheses')
    end

    it 'reports an offence for correct + opposite' do
      src = ['def func(a, b)',
             'end',
             'def func a, b',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'reports an offence for class def with parameters but no parens' do
      src = ['def Test.func a, b',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
    end

    it 'accepts def with no args and no parens' do
      src = ['def func',
             'end']
      inspect_source(cop, src)
      expect(cop.offences).to be_empty
    end

    it 'auto-adds required parens for a def' do
      new_source = autocorrect_source(cop, 'def test param; end')
      expect(new_source).to eq('def test(param); end')
    end

    it 'auto-adds required parens for a defs' do
      new_source = autocorrect_source(cop, 'def self.test param; end')
      expect(new_source).to eq('def self.test(param); end')
    end

    it 'auto-adds required parens to argument lists on multiple lines' do
      new_source = autocorrect_source(cop, ['def test one,', 'two', 'end'])
      expect(new_source).to eq("def test(one,\ntwo)\nend")
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it 'reports an offence for def with parameters with parens' do
      src = ['def func(a, b)',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                 'require_parentheses')
    end

    it 'reports an offence for opposite + correct' do
      src = ['def func(a, b)',
             'end',
             'def func a, b',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'reports an offence for class def with parameters with parens' do
      src = ['def Test.func(a, b)',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
    end

    it 'reports an offence for def with no args and parens' do
      src = ['def func()',
             'end']
      inspect_source(cop, src)
      expect(cop.offences.size).to eq(1)
    end

    it 'auto-removes the parens' do
      new_source = autocorrect_source(cop, 'def test(param); end')
      expect(new_source).to eq('def test param; end')
    end

    it 'auto-removes the parens for defs' do
      new_source = autocorrect_source(cop, 'def self.test(param); end')
      expect(new_source).to eq('def self.test param; end')
    end
  end
end
