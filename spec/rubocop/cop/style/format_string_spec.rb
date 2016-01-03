# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::FormatString, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is sprintf' do
    let(:cop_config) { { 'EnforcedStyle' => 'sprintf' } }
    it 'registers an offense for a string followed by something' do
      inspect_source(cop,
                     'puts "%d" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'registers an offense for something followed by an array' do
      inspect_source(cop,
                     'puts x % [10, 11]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'does not register an offense for numbers' do
      inspect_source(cop,
                     'puts 10 % 4')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for ambiguous cases' do
      inspect_source(cop,
                     'puts x % 4')
      expect(cop.offenses).to be_empty

      inspect_source(cop,
                     'puts x % Y')
      expect(cop.offenses).to be_empty
    end

    it 'works if the first operand contains embedded expressions' do
      inspect_source(cop,
                     'puts "#{x * 5} %d #{@test}" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `String#%`.'])
    end

    it 'registers an offense for format' do
      inspect_source(cop,
                     'format(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `format`.'])
    end

    it 'registers an offense for format with 2 arguments' do
      inspect_source(cop,
                     'format("%X", 123)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `sprintf` over `format`.'])
    end
  end

  context 'when enforced style is format' do
    let(:cop_config) { { 'EnforcedStyle' => 'format' } }

    it 'registers an offense for a string followed by something' do
      inspect_source(cop,
                     'puts "%d" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'registers an offense for something followed by an array' do
      inspect_source(cop,
                     'puts x % [10, 11]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'does not register an offense for numbers' do
      inspect_source(cop,
                     'puts 10 % 4')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for ambiguous cases' do
      inspect_source(cop,
                     'puts x % 4')
      expect(cop.offenses).to be_empty

      inspect_source(cop,
                     'puts x % Y')
      expect(cop.offenses).to be_empty
    end

    it 'works if the first operand contains embedded expressions' do
      inspect_source(cop,
                     'puts "#{x * 5} %d #{@test}" % 10')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `String#%`.'])
    end

    it 'registers an offense for sprintf' do
      inspect_source(cop,
                     'sprintf(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `sprintf`.'])
    end

    it 'registers an offense for sprintf with 2 arguments' do
      inspect_source(cop,
                     "sprintf('%020d', 123)")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `format` over `sprintf`.'])
    end
  end

  context 'when enforced style is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for format' do
      inspect_source(cop,
                     'format(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `format`.'])
    end

    it 'registers an offense for sprintf' do
      inspect_source(cop,
                     'sprintf(something, a, b)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `sprintf`.'])
    end

    it 'registers an offense for sprintf with 3 arguments' do
      inspect_source(cop,
                     'format("%d %04x", 123, 123)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Favor `String#%` over `format`.'])
    end

    it 'accepts format with 1 argument' do
      inspect_source(cop,
                     'format :xml')
      expect(cop.offenses).to be_empty
    end

    it 'accepts sprintf with 1 argument' do
      inspect_source(cop,
                     'sprintf :xml')
      expect(cop.offenses).to be_empty
    end

    it 'accepts format without arguments' do
      inspect_source(cop,
                     'format')
      expect(cop.offenses).to be_empty
    end

    it 'accepts sprintf without arguments' do
      inspect_source(cop,
                     'sprintf')
      expect(cop.offenses).to be_empty
    end

    it 'accepts String#%' do
      inspect_source(cop,
                     'puts "%d" % 10')
      expect(cop.offenses).to be_empty
    end
  end
end
