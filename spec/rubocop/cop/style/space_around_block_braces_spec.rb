# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAroundBlockBraces, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    {
      'EnforcedStyle' => 'space_inside_braces',
      'SpaceBeforeBlockParameters' => true
    }
  end

  it 'accepts braces surrounded by spaces' do
    inspect_source(cop, ['each { puts }'])
    expect(cop.messages).to be_empty
    expect(cop.highlights).to be_empty
  end

  it 'registers an offence for left brace without outer space' do
    inspect_source(cop, ['each{ puts }'])
    expect(cop.messages).to eq(['Space missing to the left of {.'])
    expect(cop.highlights).to eq(['{'])
  end

  it 'registers an offence for left brace without inner space' do
    inspect_source(cop, ['each {puts }'])
    expect(cop.messages).to eq(['Space missing inside {.'])
    expect(cop.highlights).to eq(['{'])
  end

  it 'registers an offence for right brace without inner space' do
    inspect_source(cop, ['each { puts}'])
    expect(cop.messages).to eq(['Space missing inside }.'])
    expect(cop.highlights).to eq(['}'])
  end

  context 'with passed in parameters' do
    it 'accepts left brace with inner space' do
      inspect_source(cop, ['each { |x| puts }'])
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offence for left brace without inner space' do
      inspect_source(cop, ['each {|x| puts }'])
      expect(cop.messages).to eq(['Space between { and | missing.'])
      expect(cop.highlights).to eq(['{'])
    end

    context 'and space before block parameters not allowed' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'space_inside_braces',
          'SpaceBeforeBlockParameters' => false
        }
      end

      it 'registers an offence for left brace with inner space' do
        inspect_source(cop, ['each { |x| puts }'])
        expect(cop.messages).to eq(['Space between { and | detected.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'accepts left brace without inner space' do
        inspect_source(cop, ['each {|x| puts }'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end
    end
  end

  context 'configured with no_space_inside_braces' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'no_space_inside_braces',
        'SpaceBeforeBlockParameters' => true
      }
    end

    it 'accepts braces without spaces inside' do
      inspect_source(cop, ['each {puts}'])
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offence for left brace with inner space' do
      inspect_source(cop, ['each { puts}'])
      expect(cop.messages).to eq(['Space inside { detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'registers an offence for right brace with inner space' do
      inspect_source(cop, ['each {puts  }'])
      expect(cop.messages).to eq(['Space inside } detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers an offence for left brace without outer space' do
      inspect_source(cop, ['each{puts}'])
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
    end

    context 'with passed in parameters' do
      context 'and space before block parameters allowed' do
        it 'accepts left brace with inner space' do
          inspect_source(cop, ['each { |x| puts}'])
          expect(cop.messages).to eq([])
          expect(cop.highlights).to eq([])
        end

        it 'registers an offence for left brace without inner space' do
          inspect_source(cop, ['each {|x| puts}'])
          expect(cop.messages).to eq(['Space between { and | missing.'])
          expect(cop.highlights).to eq(['{'])
        end
      end

      context 'and space before block parameters not allowed' do
        let(:cop_config) do
          {
            'EnforcedStyle' => 'no_space_inside_braces',
            'SpaceBeforeBlockParameters' => false
          }
        end

        it 'registers an offence for left brace with inner space' do
          inspect_source(cop, ['each { |x| puts}'])
          expect(cop.messages).to eq(['Space between { and | detected.'])
          expect(cop.highlights).to eq([' '])
        end
      end
    end
  end
end
