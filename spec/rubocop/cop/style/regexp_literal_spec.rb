# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::RegexpLiteral, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'MaxSlashes' => 1 } }

  context 'when a regexp uses // delimiters' do
    context 'when MaxSlashes is 1' do
      it 'registers an offence for two slashes in regexp' do
        inspect_source(cop, ['x =~ /home\/\//',
                             'y =~ /etc\/top\//'])
        expect(cop.messages)
          .to eq(['Use %r for regular expressions matching more ' \
                  "than 1 '/' character."] * 2)
        expect(cop.config_to_allow_offences).to eq('MaxSlashes' => 2)
      end

      it 'accepts zero or one slash in regexp' do
        inspect_source(cop, ['x =~ /\/home/',
                             'y =~ /\//',
                             'w =~ /\//m',
                             'z =~ /a/'])
        expect(cop.offences).to be_empty
      end
    end

    context 'when MaxSlashes is 0' do
      let(:cop_config) { { 'MaxSlashes' => 0 } }

      it 'registers an offence for one slash in regexp' do
        inspect_source(cop, ['x =~ /home\//'])
        expect(cop.messages)
          .to eq(['Use %r for regular expressions matching more ' \
                  "than 0 '/' characters."])
        expect(cop.config_to_allow_offences).to eq('MaxSlashes' => 1)
      end

      it 'accepts zero slashes in regexp' do
        inspect_source(cop, ['z =~ /a/'])
        expect(cop.offences).to be_empty
      end

      it 'registers an offence for zero slashes in regexp' do
        inspect_source(cop, ['y =~ %r(etc)'])
        expect(cop.messages)
          .to eq(['Use %r only for regular expressions matching more ' \
                  "than 0 '/' characters."])
        expect(cop.config_to_allow_offences).to eq('MaxSlashes' => 1)
      end

      it 'accepts regexp with one slash' do
        inspect_source(cop, ['x =~ %r(/home)'])
        expect(cop.offences).to be_empty
      end
    end

    it 'ignores slashes do not belong regexp' do
      inspect_source(cop, ['x =~ /\s{#{x[/\s+/].length}}/'])
      expect(cop.offences).to be_empty
    end
  end

  context 'when a regexp uses %r delimiters' do
    context 'when MaxSlashes is 1' do
      it 'registers an offence for zero or one slash in regexp' do
        inspect_source(cop, ['x =~ %r(/home)',
                             'y =~ %r(etc)'])
        expect(cop.messages)
          .to eq(['Use %r only for regular expressions matching more ' \
                  "than 1 '/' character."] * 2)
        expect(cop.config_to_allow_offences).to eq('MaxSlashes' => 2)
      end

      it 'accepts regexp with two or more slashes' do
        inspect_source(cop, ['x =~ %r(/home/)',
                             'y =~ %r(/////)'])
        expect(cop.offences).to be_empty
      end
    end
  end
end
