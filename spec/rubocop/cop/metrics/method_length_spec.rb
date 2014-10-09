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

  context 'checking a method call with block' do
    shared_examples 'an unchecked block' do
      it 'accepts a block body with more than 5 lines' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    shared_examples 'a checked block' do
      it 'rejects a block body with more than 5 lines' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses[0].message)
          .to eq("Block passed to `#{name}` has too many lines. [6/5]")
        expect(cop.offenses.map(&:line).sort).to eq([3])
        expect(cop.config_to_allow_offenses).to eq('Max' => 6)
      end
    end

    let(:source) do
      ['my_dsl_method(m) do',
       '  a = 1',
       '  a = 2',
       '  a = 3',
       '  a = 4',
       '  a = 5',
       '  a = 6',
       'end']
    end

    it_behaves_like 'an unchecked block'

    context 'when the call is inside a module' do
      let(:name) { 'my_dsl_method' }
      let(:source) do
        ['module MyModule',
         '  def othermethod; 1; end',
         '  my_dsl_method(m) do',
         '    a = 1',
         '    a = 2',
         '    a = 3',
         '    a = 4',
         '    a = 5',
         '    a = 6',
         '  end',
         'end']
      end

      it_behaves_like 'a checked block'

      context 'when dsl method checks are disabled' do
        let(:cop_config) { { 'Max' => 5, 'DSLMethods' => false } }
        it_behaves_like 'an unchecked block'
      end

      context 'when invoked with an explicit receiver' do
        before { source[2] = '  x.my_dsl_method(m) do' }
        it_behaves_like 'an unchecked block'
      end

      context 'when in isolation inside the module' do
        before { source[1] = '  # a comment' }
        it_behaves_like 'a checked block'
      end
    end

    context 'when the call is inside a class' do
      let(:name) { 'my_dsl_method' }
      let(:source) do
        ['class MyClass',
         '  def othermethod; 1; end',
         '  my_dsl_method(m) do',
         '    a = 1',
         '    a = 2',
         '    a = 3',
         '    a = 4',
         '    a = 5',
         '    a = 6',
         '  end',
         'end']
      end

      it_behaves_like 'a checked block'

      context 'when dsl method checks are disabled' do
        let(:cop_config) { { 'Max' => 5, 'DSLMethods' => false } }
        it_behaves_like 'an unchecked block'
      end

      context 'when invoked with an explicit receiver' do
        before { source[2] = '  x.my_dsl_method(m) do' }
        it_behaves_like 'an unchecked block'
      end

      context 'when in isolation inside the class' do
        before { source[1] = '  # a comment' }
        it_behaves_like 'a checked block'
      end
    end
  end
end
