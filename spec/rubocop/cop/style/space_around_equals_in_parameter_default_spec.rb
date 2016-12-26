# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAroundEqualsInParameterDefault, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense for default value assignment without space' do
      inspect_source(cop, ['def f(x, y=0, z= 1)',
                           'end'])
      expect(cop.messages)
        .to eq(['Surrounding space missing in default value assignment.'] * 2)
      expect(cop.highlights).to eq(['=', '= '])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for assignment empty string without space' do
      inspect_source(cop, ['def f(x, y="", z=1)',
                           'end'])
      expect(cop.offenses.size).to eq(2)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
    end

    it 'registers an offense for assignment of empty list without space' do
      inspect_source(cop, ['def f(x, y=[])',
                           'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts default value assignment with space' do
      inspect_source(cop, ['def f(x, y = 0, z = {})',
                           'end'])
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, ['def f(x, y=0, z=1)', 'end'])
      expect(new_source).to eq(['def f(x, y = 0, z = 1)', 'end'].join("\n"))
    end

    it 'accepts default value assignment with spaces and unary + operator' do
      inspect_source(cop, ['def f(x, y = +1, z = {})',
                           'end'])
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects missing space for arguments with unary operators' do
      new_source = autocorrect_source(cop, ['def f(x=-1, y= 0, z =+1)', 'end'])
      expect(new_source).to eq(['def f(x = -1, y = 0, z = +1)',
                                'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for default value assignment with space' do
      inspect_source(cop, ['def f(x, y = 0, z =1, w= 2)',
                           'end'])
      expect(cop.messages)
        .to eq(['Surrounding space detected in default value assignment.'] * 3)
      expect(cop.highlights).to eq([' = ', ' =', '= '])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for assignment empty string with space' do
      inspect_source(cop, ['def f(x, y = "", z = 1)',
                           'end'])
      expect(cop.offenses.size).to eq(2)
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'space')
    end

    it 'registers an offense for assignment of empty list with space' do
      inspect_source(cop, ['def f(x, y = [])',
                           'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts default value assignment without space' do
      inspect_source(cop, ['def f(x, y=0, z={})',
                           'end'])
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, ['def f(x, y = 0, z= 1, w= 2)',
                                            'end'])
      expect(new_source).to eq(['def f(x, y=0, z=1, w=2)',
                                'end'].join("\n"))
    end
  end
end
