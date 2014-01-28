# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MultilineBlockChain do
  subject(:cop) { described_class.new }

  context 'with multi-line block chaining' do
    it 'registers an offence for a simple case' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c do',
                           '  d',
                           'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.highlights).to eq(['end.c'])
    end

    it 'registers an offence for a slightly more complicated case' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c1.c2 do',
                           '  d',
                           'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.highlights).to eq(['end.c1.c2'])
    end

    it 'registers two offences for a chain of three blocks' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c do',
                           '  d',
                           'end.e do',
                           '  f',
                           'end'])
      expect(cop.offences.size).to eq(2)
      expect(cop.highlights).to eq(['end.c', 'end.e'])
    end

    it 'registers an offence for a chain where the second block is ' \
      'single-line' do
      inspect_source(cop, ['Thread.list.find_all { |t|',
                           '  t.alive?',
                           '}.map { |thread| thread.object_id }'])
      expect(cop.offences.size).to eq(1)
      expect(cop.highlights).to eq(['}.map'])
    end

    it 'accepts a chain where the first block is single-line' do
      inspect_source(cop,
                     ['Thread.list.find_all { |t| t.alive? }.map { |t| ',
                      '  t.object_id',
                      '}'])
      expect(cop.offences).to be_empty
    end
  end

  it 'accepts a chain of blocks spanning one line' do
    inspect_source(cop, ['a { b }.c { d }',
                         'w do x end.y do z end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a multi-line block chained with calls on one line' do
    inspect_source(cop, ['a do',
                         '  b',
                         'end.c.d'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a chain of calls followed by a multi-line block' do
    inspect_source(cop, ['a1.a2.a3 do',
                         '  b',
                         'end'])
    expect(cop.offences).to be_empty
  end
end
