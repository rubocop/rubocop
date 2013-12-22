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
    expect(cop.messages).to eq(['Class definition is too long. [6/5]'])
    expect(cop.config_to_allow_offences).to eq('Max' => 6)
  end

  it 'accepts a class with 5 lines' do
    inspect_source(cop, ['class Test',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '  a = 5',
                         'end'])
    expect(cop.offences).to be_empty
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

  context 'when a class has inner classes' do
    it 'does not count lines of inner classes' do
      inspect_source(cop, ['class NamespaceClass',
                           '  class TestOne',
                           '    a = 1',
                           '    a = 2',
                           '    a = 3',
                           '    a = 4',
                           '    a = 5',
                           '  end',
                           '  class TestTwo',
                           '    a = 1',
                           '    a = 2',
                           '    a = 3',
                           '    a = 4',
                           '    a = 5',
                           '  end',
                           '  a = 1',
                           '  a = 2',
                           '  a = 3',
                           '  a = 4',
                           '  a = 5',
                           'end'])
      expect(cop.offences).to be_empty
    end

    it 'rejects a class with 6 lines that belong to the class directly' do
      inspect_source(cop, ['class NamespaceClass',
                           '  class TestOne',
                           '    a = 1',
                           '    a = 2',
                           '    a = 3',
                           '    a = 4',
                           '    a = 5',
                           '  end',
                           '  class TestTwo',
                           '    a = 1',
                           '    a = 2',
                           '    a = 3',
                           '    a = 4',
                           '    a = 5',
                           '  end',
                           '  a = 1',
                           '  a = 2',
                           '  a = 3',
                           '  a = 4',
                           '  a = 5',
                           '  a = 6',
                           'end'])
      expect(cop.offences.size).to eq(1)
    end
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
