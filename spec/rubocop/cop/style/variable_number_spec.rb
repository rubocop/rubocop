# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::VariableNumber, :config do
  subject(:cop) { described_class.new(config) }

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for normal case numbering in local variable' do
      inspect_source(cop, 'local1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['local1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'does not registers an offense for snake case numbering in local
     variable' do
      inspect_source(cop, 'local_1 = 1')
      expect(cop.offenses.size).to eq(0)
    end

    it 'registers an offense for normal case numbering in instance variable' do
      inspect_source(cop, '@local1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@local1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in class variable' do
      inspect_source(cop, '@@local1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@@local1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for correct + incorrect' do
      inspect_source(cop, ['local_1 = 1',
                           ' local1 = 1'])
      expect(cop.highlights).to eq(['local1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in camel case
     variable' do
      inspect_source(cop, 'myAttribute1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myAttribute1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in camel case
     instance variable name' do
      inspect_source(cop, '@myAttribute1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@myAttribute1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in local variables
     marked as unused' do
      inspect_source(cop, '_myLocal1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['_myLocal1'])
      expect(cop.messages).to eq(['Use snake_case for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in method parameter' do
      inspect_source(cop, 'def method(arg1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['arg1'])
    end

    it 'registers an offense for normal case numbering in method camel case
     parameter' do
      inspect_source(cop, 'def method(funnyArg1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['funnyArg1'])
    end
  end

  context 'when configured for normal' do
    let(:cop_config) { { 'EnforcedStyle' => 'normalcase' } }

    it 'registers an offense for snake case numbering in local variable' do
      inspect_source(cop, 'local_1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['local_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'does not registers an offense for normal case numbering in local
     variable' do
      inspect_source(cop, 'local1 = 1')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register an offense for normal case number in local
      variable' do
      inspect_source(cop, 'user1_id = 1')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register an offense for normal case number in local
      variable' do
      inspect_source(cop, 'sha256 = 3')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register on offense for normal case multi digit number in
      local variable' do
      inspect_source(cop, 'foo10_bar = 4')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register on offense for normal case multi digit number in
      local variable' do
      inspect_source(cop, 'foo_bar10 = 4')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register an offense for normal case number in the middle of
      local variable' do
      inspect_source(cop, 'target_u2f_device = nil')
      expect(cop.offenses.size).to eq(0)
    end

    it 'registers an offense for only integers in the middle' do
      inspect_source(cop, 'user_1_id = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['user_1_id'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for only integers at the end of name' do
      inspect_source(cop, 'sha_256 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['sha_256'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in instance variable' do
      inspect_source(cop, '@local_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@local_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in class variable' do
      inspect_source(cop, '@@local_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@@local_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for correct + incorrect' do
      inspect_source(cop, ['local_1 = 1',
                           ' local1 = 1'])
      expect(cop.highlights).to eq(['local_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case variable' do
      inspect_source(cop, 'myAttribute_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myAttribute_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case
     instance variable name' do
      inspect_source(cop, '@myAttribute_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@myAttribute_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case
     local variables marked as unused' do
      inspect_source(cop, '_myLocal_1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['_myLocal_1'])
      expect(cop.messages).to eq(['Use normalcase for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in method parameter' do
      inspect_source(cop, 'def method(arg_1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['arg_1'])
    end

    it 'registers an offense for snake case numbering in method camel case
     parameter' do
      inspect_source(cop, 'def method(funnyArg_1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['funnyArg_1'])
    end
  end

  context 'when configured for non integer' do
    let(:cop_config) { { 'EnforcedStyle' => 'non_integer' } }

    it 'registers an offense for snake case numbering in local variable' do
      inspect_source(cop, 'local_1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['local_1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in local variable' do
      inspect_source(cop, 'local1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['local1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'does not registers an offense for non integer numbering in local
     variable' do
      inspect_source(cop, 'localone = 1')
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not registers an offense for non integer numbering in local
     variable' do
      inspect_source(cop, 'local_one = 1')
      expect(cop.offenses.size).to eq(0)
    end

    it 'registers an offense for snake case numbering in instance variable' do
      inspect_source(cop, '@local_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@local_1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in instance variable' do
      inspect_source(cop, '@local1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@local1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case variable' do
      inspect_source(cop, 'myAttribute_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myAttribute_1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in camel case
     variable' do
      inspect_source(cop, 'myAttribute1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myAttribute1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case
     instance variable' do
      inspect_source(cop, '@myAttribute_1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@myAttribute_1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in camel case
     instance variable' do
      inspect_source(cop, '@myAttribute1 = 3')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['@myAttribute1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in camel case
     local variables marked as unused' do
      inspect_source(cop, '_myLocal_1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['_myLocal_1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for normal case numbering in camel case
     local variables marked as unused' do
      inspect_source(cop, '_myLocal1 = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['_myLocal1'])
      expect(cop.messages).to eq(['Use non_integer for variable numbers.'])
    end

    it 'registers an offense for snake case numbering in method parameter' do
      inspect_source(cop, 'def method(arg_1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['arg_1'])
    end

    it 'registers an offense for normal case numbering in method parameter' do
      inspect_source(cop, 'def method(arg1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['arg1'])
    end

    it 'registers an offense for snake case numbering in method camel case
     parameter' do
      inspect_source(cop, 'def method(myArg_1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myArg_1'])
    end

    it 'registers an offense for normal case numbering in method camel case
     parameter' do
      inspect_source(cop, 'def method(myArg1); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['myArg1'])
    end
  end
end
