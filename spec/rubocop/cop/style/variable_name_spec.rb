# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::VariableName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'always accepted' do
    it 'accepts screaming snake case globals' do
      inspect_source(cop, '$MY_GLOBAL = 0')
      expect(cop.offences).to be_empty
    end

    it 'accepts screaming snake case constants' do
      inspect_source(cop, 'MY_CONSTANT = 0')
      expect(cop.offences).to be_empty
    end

    it 'accepts assigning to camel case constant' do
      inspect_source(cop, 'Paren = Struct.new :left, :right, :kind')
      expect(cop.offences).to be_empty
    end

    it 'accepts assignment with indexing of self' do
      inspect_source(cop, 'self[:a] = b')
      expect(cop.offences).to be_empty
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offence for camel case in local variable name' do
      inspect_source(cop, 'myLocal = 1')
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['myLocal'])
    end

    it 'registers an offence for camel case in instance variable name' do
      inspect_source(cop, '@myAttribute = 3')
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['@myAttribute'])
    end

    it 'registers an offence for camel case in setter name' do
      inspect_source(cop, 'self.mySetter = 2')
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['mySetter'])
    end

    include_examples 'always accepted'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'accepts camel case in local variable name' do
      inspect_source(cop, 'myLocal = 1')
      expect(cop.offences).to be_empty
    end

    it 'accepts camel case in instance variable name' do
      inspect_source(cop, '@myAttribute = 3')
      expect(cop.offences).to be_empty
    end

    it 'accepts camel case in setter name' do
      inspect_source(cop, 'self.mySetter = 2')
      expect(cop.offences).to be_empty
    end

    include_examples 'always accepted'
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source(cop, 'a = 3') }
        .to raise_error(RuntimeError)
    end
  end
end
