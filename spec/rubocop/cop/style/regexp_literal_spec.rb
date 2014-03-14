# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::RegexpLiteral, :config do
  subject(:cop) { described_class.new(config) }

  context 'when MaxSlashes is -1' do
    let(:cop_config) { { 'MaxSlashes' => -1 } }

    it 'fails' do
      expect { inspect_source(cop, ['x =~ /home/']) }
        .to raise_error(RuntimeError)
    end
  end

  context 'when MaxSlashes is 0' do
    let(:cop_config) { { 'MaxSlashes' => 0 } }

    it 'registers an offense for one slash in // regexp' do
      inspect_source(cop, ['x =~ /home\//'])
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 0 '/' characters."])
      expect(cop.config_to_allow_offenses).to eq('MaxSlashes' => 1)
    end

    it 'accepts zero slashes in // regexp' do
      inspect_source(cop, ['z =~ /a/'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for zero slashes in %r regexp' do
      inspect_source(cop, ['y =~ %r(etc)'])
      expect(cop.messages)
        .to eq(['Use %r only for regular expressions matching more ' \
                "than 0 '/' characters."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts %r regexp with one slash' do
      inspect_source(cop, ['x =~ %r(/home)'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'when MaxSlashes is 1' do
    let(:cop_config) { { 'MaxSlashes' => 1 } }

    it 'registers an offense for two slashes in // regexp' do
      inspect_source(cop, ['x =~ /home\/\//',
                           'y =~ /etc\/top\//'])
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 1 '/' character."] * 2)
      expect(cop.config_to_allow_offenses).to eq('MaxSlashes' => 2)
    end

    it 'registers offenses for slashes with too many and %r with too few' do
      inspect_source(cop, ['x =~ /home\/\//',
                           'y =~ %r{home}'])
      expect(cop.messages)
        .to eq(['Use %r for regular expressions matching more ' \
                "than 1 '/' character.",
                'Use %r only for regular expressions matching more ' \
                "than 1 '/' character."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers offenses for %r with too few and slashes with too many' do
      inspect_source(cop, ['y =~ %r{home}',
                           'x =~ /home\/\//'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts zero or one slash in // regexp' do
      inspect_source(cop, ['x =~ /\/home/',
                           'y =~ /\//',
                           'w =~ /\//m',
                           'z =~ /a/'])
      expect(cop.offenses).to be_empty
    end

    it 'ignores slashes do not belong // regexp' do
      inspect_source(cop, ['x =~ /\s{#{x[/\s+/].length}}/'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for zero or one slash in %r regexp' do
      inspect_source(cop, ['x =~ %r(/home)',
                           'y =~ %r(etc)'])
      expect(cop.messages)
        .to eq(['Use %r only for regular expressions matching more ' \
                "than 1 '/' character."] * 2)
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts %r regexp with two or more slashes' do
      inspect_source(cop, ['x =~ %r(/home/)',
                           'y =~ %r(/////)'])
      expect(cop.offenses).to be_empty
    end
  end
end
