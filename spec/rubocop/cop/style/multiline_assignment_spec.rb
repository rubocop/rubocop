# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MultilineAssignment do
  subject(:cop) { described_class.new }

  it 'ignores single-line assignment' do
    inspect_source(cop, ['a = this.is.it'])

    expect(cop.offenses).to be_empty
  end

  context 'with multi-line assignment' do
    it 'registers an offense for a simple case' do
      inspect_source(cop, ['a = this.',
                           '    is.it'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['='])
    end

    it 'registers an offense for an almost correct case' do
      inspect_source(cop, ['a =',
                           'this.',
                           'is.it'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['='])
    end

    it 'accepts correct case' do
      inspect_source(cop, ['a = ',
                           '  this.',
                           '  is.it'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts correct case with subsequent indentation for chained method' do
      inspect_source(cop, ['a = ',
                           '  this.',
                           '    is.it'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts hash' do
      inspect_source(cop, ['a = {',
                           '  b: :c',
                           '}'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts array' do
      inspect_source(cop, ['a = [',
                           '  :b, :c',
                           ']'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts simple unchained block' do
      inspect_source(cop, ['a = b.map { |c|',
                           '  c.d',
                           '}'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts unchained block when defining a Struct' do
      inspect_source(cop, ['a = Struct.new(:a) do',
                           '  def a',
                           '    :a',
                           '  end',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts unchained block when defining a lambda' do
      inspect_source(cop, ['a = ->(f) {',
                           '  ->(x) { f.(->(*v) { x.(x).(*v) }) }.(',
                           '  ->(x) { f.(->(*v) { x.(x).(*v) }) } )',
                           '}'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for a chained block' do
      inspect_source(cop, ['a = b.map { |c|',
                           '  c.d',
                           '}.sort'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['='])
    end

    it 'registers an offense for a chained block' do
      inspect_source(cop, ['a = b.map { |c|',
                           '  c.d',
                           '}.map { |e|',
                           '  e.f',
                           '}'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['='])
    end
  end
end
