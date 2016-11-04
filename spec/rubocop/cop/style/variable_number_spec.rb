# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::VariableNumber, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples :offense do |style, variable|
    it "registers an offense for #{variable} in #{style}" do
      inspect_source(cop, "#{variable} = 1")

      expect(cop.messages).to eq(["Use #{style} for variable numbers."])
      expect(cop.highlights).to eq([variable])
    end
  end

  shared_examples :accepts do |style, variable|
    it "accepts #{variable} in #{style}" do
      inspect_source(cop, "#{variable} = 1")

      expect(cop.offenses).to be_empty
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it_behaves_like :offense, 'snake_case', 'local1'
    it_behaves_like :offense, 'snake_case', '@local1'
    it_behaves_like :offense, 'snake_case', '@@local1'
    it_behaves_like :offense, 'snake_case', 'camelCase1'
    it_behaves_like :offense, 'snake_case', '@camelCase1'
    it_behaves_like :offense, 'snake_case', '_unused1'
    it_behaves_like :offense, 'snake_case', 'aB1'

    it_behaves_like :accepts, 'snake_case', 'local_1'
    it_behaves_like :accepts, 'snake_case', 'local_12'
    it_behaves_like :accepts, 'snake_case', 'local_123'
    it_behaves_like :accepts, 'snake_case', 'local_'
    it_behaves_like :accepts, 'snake_case', 'aB_1'
    it_behaves_like :accepts, 'snake_case', 'a_1_b'
    it_behaves_like :accepts, 'snake_case', 'a_1_b_1'
    it_behaves_like :accepts, 'snake_case', '_'
    it_behaves_like :accepts, 'snake_case', '_foo'
    it_behaves_like :accepts, 'snake_case', '@foo'
    it_behaves_like :accepts, 'snake_case', '@__foo__'

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

    it_behaves_like :offense, 'normalcase', 'local_1'
    it_behaves_like :offense, 'normalcase', 'sha_256'
    it_behaves_like :offense, 'normalcase', '@local_1'
    it_behaves_like :offense, 'normalcase', '@@local_1'
    it_behaves_like :offense, 'normalcase', 'myAttribute_1'
    it_behaves_like :offense, 'normalcase', '@myAttribute_1'
    it_behaves_like :offense, 'normalcase', '_myLocal_1'
    it_behaves_like :offense, 'normalcase', 'localFOO_1'
    it_behaves_like :offense, 'normalcase', 'local_FOO_1'

    it_behaves_like :accepts, 'normalcase', 'local1'
    it_behaves_like :accepts, 'normalcase', 'local_'
    it_behaves_like :accepts, 'normalcase', 'user1_id'
    it_behaves_like :accepts, 'normalcase', 'sha256'
    it_behaves_like :accepts, 'normalcase', 'foo10_bar'
    it_behaves_like :accepts, 'normalcase', 'target_u2f_device'
    it_behaves_like :accepts, 'normalcase', 'localFOO1'
    it_behaves_like :accepts, 'normalcase', 'snake_case'
    it_behaves_like :accepts, 'normalcase', 'user_1_id'
    it_behaves_like :accepts, 'normalcase', '_'
    it_behaves_like :accepts, 'normalcase', '_foo'
    it_behaves_like :accepts, 'normalcase', '@foo'
    it_behaves_like :accepts, 'normalcase', '@__foo__'

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

    it_behaves_like :offense, 'non_integer', 'local_1'
    it_behaves_like :offense, 'non_integer', 'local1'
    it_behaves_like :offense, 'non_integer', '@local_1'
    it_behaves_like :offense, 'non_integer', '@local1'
    it_behaves_like :offense, 'non_integer', 'myAttribute_1'
    it_behaves_like :offense, 'non_integer', 'myAttribute1'
    it_behaves_like :offense, 'non_integer', '@myAttribute_1'
    it_behaves_like :offense, 'non_integer', '@myAttribute1'
    it_behaves_like :offense, 'non_integer', '_myLocal_1'
    it_behaves_like :offense, 'non_integer', '_myLocal1'

    it_behaves_like :accepts, 'non_integer', 'localone'
    it_behaves_like :accepts, 'non_integer', 'local_one'
    it_behaves_like :accepts, 'non_integer', 'local_'
    it_behaves_like :accepts, 'non_integer', '@foo'
    it_behaves_like :accepts, 'non_integer', '@@foo'
    it_behaves_like :accepts, 'non_integer', 'fooBar'
    it_behaves_like :accepts, 'non_integer', '_'
    it_behaves_like :accepts, 'non_integer', '_foo'
    it_behaves_like :accepts, 'non_integer', '@__foo__'

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
