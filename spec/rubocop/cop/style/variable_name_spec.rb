# frozen_string_literal: true

describe RuboCop::Cop::Style::VariableName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'always accepted' do
    it 'accepts screaming snake case globals' do
      expect_no_offenses('$MY_GLOBAL = 0')
    end

    it 'accepts screaming snake case constants' do
      expect_no_offenses('MY_CONSTANT = 0')
    end

    it 'accepts assigning to camel case constant' do
      expect_no_offenses('Paren = Struct.new :left, :right, :kind')
    end

    it 'accepts assignment with indexing of self' do
      expect_no_offenses('self[:a] = b')
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
      inspect_source(cop, <<-END.strip_indent)
        my_local = 1
        myLocal = 1
      END
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

    it 'registers an offense for camel case local variables marked as unused' do
      inspect_source(cop, '_myLocal = 1')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['_myLocal'])
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
      inspect_source(cop, <<-END.strip_indent)
        my_local = 1
        myLocal = 1
      END
      expect(cop.highlights).to eq(['my_local'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts camel case in local variable name' do
      expect_no_offenses('myLocal = 1')
    end

    it 'accepts camel case in instance variable name' do
      expect_no_offenses('@myAttribute = 3')
    end

    it 'accepts camel case in class variable name' do
      expect_no_offenses('@@myAttr = 2')
    end

    it 'registers an offense for snake case in method parameter' do
      inspect_source(cop, 'def method(funny_arg); end')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['funny_arg'])
    end

    it 'accepts camel case local variables marked as unused' do
      expect_no_offenses('_myLocal = 1')
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
