# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::VariableName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'always accepted' do
    it 'accepts screaming snake case globals' do
      inspect_source(cop, '$MY_GLOBAL = 0')
      expect(cop.offenses).to be_empty
    end

    it 'accepts screaming snake case constants' do
      inspect_source(cop, 'MY_CONSTANT = 0')
      expect(cop.offenses).to be_empty
    end

    it 'accepts assigning to camel case constant' do
      inspect_source(cop, 'Paren = Struct.new :left, :right, :kind')
      expect(cop.offenses).to be_empty
    end

    it 'accepts assignment with indexing of self' do
      inspect_source(cop, 'self[:a] = b')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case in local variable name' do
      inspect_source(cop, 'myLocal = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myLocal'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'camelCase')
    end

    it 'registers an offense for correct + opposite' do
      inspect_source(cop, ['my_local = 1',
                           'myLocal = 1'])
      expect(cop.highlights).to eq(['myLocal'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for camel case in instance variable name' do
      inspect_source(cop, '@myAttribute = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@myAttribute'])
    end

    it 'registers an offense for camel case in class variable name' do
      inspect_source(cop, '@@myAttr = 2')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@@myAttr'])
    end

    it 'registers an offense for camel case in method parameter' do
      inspect_source(cop, 'def method(funnyArg); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['funnyArg'])
    end

    include_examples 'always accepted'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'registers an offense for snake case in local variable name' do
      inspect_source(cop, 'my_local = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['my_local'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'snake_case')
    end

    it 'registers an offense for opposite + correct' do
      inspect_source(cop, ['my_local = 1',
                           'myLocal = 1'])
      expect(cop.highlights).to eq(['my_local'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts camel case in local variable name' do
      inspect_source(cop, 'myLocal = 1')
      expect(cop.offenses).to be_empty
    end

    it 'accepts camel case in instance variable name' do
      inspect_source(cop, '@myAttribute = 3')
      expect(cop.offenses).to be_empty
    end

    it 'accepts camel case in class variable name' do
      inspect_source(cop, '@@myAttr = 2')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for snake case in method parameter' do
      inspect_source(cop, 'def method(funny_arg); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['funny_arg'])
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
