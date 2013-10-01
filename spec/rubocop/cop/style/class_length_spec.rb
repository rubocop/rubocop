# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ClassLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  it 'rejects a class with more than 5 lines' do
    inspect_source(cop, ['class Test',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a class with less than 5 lines' do
    inspect_source(cop, ['class Test',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not count blank lines' do
    inspect_source(cop, ['class Test',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '',
                         '',
                         '  a = 7',
                         'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts empty classes' do
    inspect_source(cop, ['class Test',
                         'end'])
    expect(cop.offences).to be_empty
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      inspect_source(cop, ['class Test',
                           '  a = 1',
                           '  #a = 2',
                           '  a = 3',
                           '  #a = 4',
                           '  a = 5',
                           '  a = 6',
                           'end'])
      expect(cop.offences.size).to eq(1)
    end
  end
end
