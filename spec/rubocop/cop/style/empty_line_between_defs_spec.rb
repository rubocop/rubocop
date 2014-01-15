# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EmptyLineBetweenDefs, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowAdjacentOneLineDefs' => false } }

  it 'finds offences in inner classes' do
    source = ['class K',
              '  def m',
              '  end',
              '  class J',
              '    def n',
              '    end',
              '    def o',
              '    end',
              '  end',
              '  # checks something',
              '  def p',
              '  end',
              'end']
    inspect_source(cop, source)
    expect(cop.offences.size).to eq(1)
    expect(cop.offences.map(&:line).sort).to eq([7])
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows a line with code' do
    source = ['x = 0',
              'def m',
              'end']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows code and a comment' do
    source = ['  x = 0',
              '  # 123',
              '  def m',
              '  end']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  it 'accepts the first def without leading empty line in a class' do
    source = ['class K',
              '  def m',
              '  end',
              'end']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  it 'accepts a def that follows an empty line and then a comment' do
    source = ['class A',
              '  # calculates value',
              '  def m',
              '  end',
              '',
              '  private',
              '  # calculates size',
              '  def n',
              '  end',
              'end'
             ]
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  it 'accepts a def that is the first of a module' do
    source = ['module Util',
              '  public',
              '  #',
              '  def html_escape(s)',
              '  end',
              'end'
             ]
    inspect_source(cop, source)
    expect(cop.messages).to be_empty
  end

  it 'accepts a nested def' do
    source = ['def mock_model(*attributes)',
              '  Class.new do',
              '    def initialize(attrs)',
              '    end',
              '  end',
              'end'
             ]
    inspect_source(cop, source)
    expect(cop.messages).to be_empty
  end

  it 'registers an offence for adjacent one-liners by default' do
    source = ['def a; end',
              'def b; end']
    inspect_source(cop, source)
    expect(cop.offences.size).to eq(1)
  end

  context 'when AllowAdjacentOneLineDefs is enabled' do
    let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

    it 'accepts adjacent one-liners' do
      source = ['def a; end',
                'def b; end']
      inspect_source(cop, source)
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for adjacent defs if some are multi-line' do
      source = ['def a; end',
                'def b; end',
                'def c', # Not a one-liner, so this is an offence.
                'end',
                # Also an offence since previous was multi-line:
                'def d; end'
               ]
      inspect_source(cop, source)
      expect(cop.offences.map(&:line)).to eq([3, 5])
    end
  end
end
