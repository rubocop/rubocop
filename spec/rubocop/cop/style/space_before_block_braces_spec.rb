# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceBeforeBlockBraces do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/SpaceBeforeBlockBraces']
             .merge(cop_config)
    RuboCop::Config.new('Style/BlockDelimiters' => { 'Enabled' => false },
                        'Style/SpaceBeforeBlockBraces' => merged)
  end
  let(:cop_config) do
    {
      'EnforcedStyle' => 'space',
      'EnforcedStyleAfterStabbyArrow' => 'inherit'
    }
  end

  context 'when EnforcedStyle is space' do
    it 'accepts braces surrounded by spaces' do
      inspect_source(cop, 'each { puts }')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for left brace without outer space' do
      inspect_source(cop, 'each{ puts }')
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
    end

    it 'registers an offense for opposite + correct style' do
      inspect_source(cop,
                     ['each{ puts }',
                      'each { puts }'])
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each{}')
      expect(new_source).to eq('each {}')
    end

    it 'accepts braces after stabby arrow surrounded by spaces' do
      inspect_source(cop, '-> { puts "->" }')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'auto-corrects missing space after stabby arrow' do
      new_source = autocorrect_source(cop, '->{ puts "->" }')
      expect(new_source).to eq('-> { puts "->" }')
    end

    it 'registers an offense for left brace after stabby arrow ' \
       'without outer space' do
      inspect_source(cop, '->{ puts "->" }')
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
    end

    context 'with EnforcedStyleAfterStabbyArrow set to no_space' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'space',
          'EnforcedStyleAfterStabbyArrow' => 'no_space'
        }
      end

      it 'accepts missing space after stabby arrow' do
        inspect_source(cop, '->{ puts "->" }')
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'registers an offense for braces surrounded by spaces ' \
         'after stabby arrow' do
        inspect_source(cop, '-> { puts "->" }')
        expect(cop.messages).to eq(['Space detected to the left of {.'])
        expect(cop.highlights).to eq([' '])
        expect(cop.config_to_allow_offenses).to eq(
          'EnforcedStyle' => 'space',
          'EnforcedStyleAfterStabbyArrow' => %w(inherit space)
        )
      end

      it 'auto-corrects unwanted space' do
        new_source = autocorrect_source(cop, '-> { puts "->" }')
        expect(new_source).to eq('->{ puts "->" }')
      end
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'no_space',
        'EnforcedStyleAfterStabbyArrow' => 'inherit'
      }
    end

    it 'registers an offense for braces surrounded by spaces' do
      inspect_source(cop, 'each { puts }')
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'space')
    end

    it 'registers an offense for correct + opposite style' do
      inspect_source(cop,
                     ['each{ puts }',
                      'each { puts }'])
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, 'each {}')
      expect(new_source).to eq('each{}')
    end

    it 'accepts left brace without outer space' do
      inspect_source(cop, 'each{ puts }')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'accepts left brace after stabby arrow without outer space' do
      inspect_source(cop, '->{ puts "->" }')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for braces surrounded by spaces ' \
       'after stabby arrow' do
      inspect_source(cop, '-> { puts "->" }')
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'space')
    end

    it 'auto-corrects unwanted space after stabby arrow' do
      new_source = autocorrect_source(cop, '-> { puts "->" }')
      expect(new_source).to eq('->{ puts "->" }')
    end

    context 'with EnforcedStyleAfterStabbyArrow set to space' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'no_space',
          'EnforcedStyleAfterStabbyArrow' => 'space'
        }
      end

      it 'accepts braces after stabby arrow surrounded by spaces' do
        inspect_source(cop, '-> { puts "->" }')
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'auto-corrects missing space after stabby arrow' do
        new_source = autocorrect_source(cop, '->{ puts "->" }')
        expect(new_source).to eq('-> { puts "->" }')
      end

      it 'registers an offense for left brace after stabby arrow ' \
         'without outer space' do
        inspect_source(cop, '->{ puts "->" }')
        expect(cop.messages).to eq(['Space missing to the left of {.'])
        expect(cop.highlights).to eq(['{'])
        expect(cop.config_to_allow_offenses).to eq(
          'EnforcedStyle' => 'no_space',
          'EnforcedStyleAfterStabbyArrow' => %w(inherit no_space)
        )
      end
    end
  end
end
