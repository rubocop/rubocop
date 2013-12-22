# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::For, :config do
  subject(:cop) { described_class.new(config) }

  context 'when each is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'each' } }

    it 'registers an offence for for' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer *each* over *for*.'])
      expect(cop.highlights).to eq(['for'])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'for')
    end

    it 'registers an offence for opposite + correct style' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer *each* over *for*.'])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'accepts multiline each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts :for' do
      inspect_source(cop, ['[:for, :ala, :bala]'])
      expect(cop.offences).to be_empty
    end

    it 'accepts def for' do
      inspect_source(cop, ['def for; end'])
      expect(cop.offences).to be_empty
    end
  end

  context 'when for is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'for' } }

    it 'accepts for' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for multiline each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer *for* over *each*.'])
      expect(cop.highlights).to eq(['each'])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'each')
    end

    it 'registers an offence for correct + opposite style' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer *for* over *each*.'])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'accepts single line each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each { |n| puts n }',
                      'end'])
      expect(cop.offences).to be_empty
    end
  end
end
