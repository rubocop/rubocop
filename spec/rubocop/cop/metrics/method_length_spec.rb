# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Metrics::MethodLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  it 'rejects a method with more than 5 lines' do
    inspect_source(cop, ['def m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.config_to_allow_offenses).to eq('Max' => 6)
  end

  it 'accepts a method with less than 5 lines' do
    inspect_source(cop, ['def m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not count blank lines' do
    inspect_source(cop, ['def m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '',
                         '',
                         '  a = 7',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts empty methods' do
    inspect_source(cop, ['def m()',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'is not fooled by one-liner methods, syntax #1' do
    inspect_source(cop, ['def one_line; 10 end',
                         'def self.m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'is not fooled by one-liner methods, syntax #2' do
    inspect_source(cop, ['def one_line(test) 10 end',
                         'def self.m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'checks class methods, syntax #1' do
    inspect_source(cop, ['def self.m()',
                         '  a = 1',
                         '  a = 2',
                         '  a = 3',
                         '  a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
  end

  it 'checks class methods, syntax #2' do
    inspect_source(cop, ['class K',
                         '  class << self',
                         '    def m()',
                         '      a = 1',
                         '      a = 2',
                         '      a = 3',
                         '      a = 4',
                         '      a = 5',
                         '      a = 6',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([3])
  end

  it 'properly counts lines when method ends with block' do
    inspect_source(cop, ['def m()',
                         '  something do',
                         '    a = 2',
                         '    a = 3',
                         '    a = 4',
                         '    a = 5',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
  end

  it 'does not count commented lines by default' do
    inspect_source(cop, ['def m()',
                         '  a = 1',
                         '  #a = 2',
                         '  a = 3',
                         '  #a = 4',
                         '  a = 5',
                         '  a = 6',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      inspect_source(cop, ['def m()',
                           '  a = 1',
                           '  #a = 2',
                           '  a = 3',
                           '  #a = 4',
                           '  a = 5',
                           '  a = 6',
                           'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.map(&:line).sort).to eq([1])
    end
  end

  describe 'ignoring methods' do
    context 'an instance method is ignored' do
      before { cop_config['IgnoredMethods'] = ['K#some_method'] }

      it 'does not reject the method' do
        inspect_source(cop, ['class K',
                             '  def some_method()',
                             '    a = 1',
                             '    a = 2',
                             '    a = 3',
                             '    a = 4',
                             '    a = 5',
                             '    a = 6',
                             '  end',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'a class method is ignored' do
      before { cop_config['IgnoredMethods'] = ['K.some_method'] }

      it 'does not reject the method' do
        inspect_source(cop, ['class K',
                             '  def self.some_method()',
                             '    a = 1',
                             '    a = 2',
                             '    a = 3',
                             '    a = 4',
                             '    a = 5',
                             '    a = 6',
                             '  end',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'handles class methods, syntax #2' do
        inspect_source(cop, ['class K',
                             '  class << self',
                             '    def some_method()',
                             '      a = 1',
                             '      a = 2',
                             '      a = 3',
                             '      a = 4',
                             '      a = 5',
                             '      a = 6',
                             '    end',
                             '  end',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'classes inside a module' do
      before { cop_config['IgnoredMethods'] = ['J::K#some_method'] }

      it 'does not reject the ignored method' do
        inspect_source(cop, ['module J',
                             '  class K',
                             '    def some_method()',
                             '      a = 1',
                             '      a = 2',
                             '      a = 3',
                             '      a = 4',
                             '      a = 5',
                             '      a = 6',
                             '    end',
                             '  end',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'multiple ignored methods' do
      before do
        cop_config['IgnoredMethods'] = %w(
          K.some_method
          K.another_method
          K#last_method
        )
      end

      it 'does not reject any ignored methods' do
        inspect_source(cop, ['class K',
                             '  class << self',
                             '    def some_method()',
                             '      a = 1',
                             '      a = 2',
                             '      a = 3',
                             '      a = 4',
                             '      a = 5',
                             '      a = 6',
                             '    end',
                             '  end',
                             '  def self.another_method()',
                             '    a = 1',
                             '    a = 2',
                             '    a = 3',
                             '    a = 4',
                             '    a = 5',
                             '    a = 6',
                             '  end',
                             '  def last_method()',
                             '    a = 1',
                             '    a = 2',
                             '    a = 3',
                             '    a = 4',
                             '    a = 5',
                             '    a = 6',
                             '  end',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
