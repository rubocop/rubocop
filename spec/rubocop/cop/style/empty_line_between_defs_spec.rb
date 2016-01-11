# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLineBetweenDefs, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowAdjacentOneLineDefs' => false } }

  it 'finds offenses in inner classes' do
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
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([7])
  end

  context 'when there are only comments between defs' do
    let(:source) do
      ['class J',
       '  def n',
       '  end # n-related',
       '  # checks something o-related',
       '  # and more',
       '  def o',
       '  end',
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(['class J',
                               '  def n',
                               '  end # n-related',
                               '',
                               '  # checks something o-related',
                               '  # and more',
                               '  def o',
                               '  end',
                               'end'].join("\n"))
    end
  end

  context 'conditional method definitions' do
    it 'accepts defs inside a conditional without blank lines in between' do
      source = ['if condition',
                '  def foo',
                '    true',
                '  end',
                'else',
                '  def foo',
                '    false',
                '  end',
                'end']
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for consecutive defs inside a conditional' do
      source = ['if condition',
                '  def foo',
                '    true',
                '  end',
                '  def bar',
                '    true',
                '  end',
                'else',
                '  def foo',
                '    false',
                '  end',
                'end']
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'class methods' do
    context 'adjacent class methods' do
      let(:offending_source) do
        ['class Test',
         '  def self.foo',
         '    true',
         '  end',
         '  def self.bar',
         '    true',
         '  end',
         'end']
      end

      it 'registers an offense for missing blank line between methods' do
        inspect_source(cop, offending_source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects it' do
        corrected = autocorrect_source(cop, offending_source)
        expect(corrected).to eq(['class Test',
                                 '  def self.foo',
                                 '    true',
                                 '  end',
                                 '',
                                 '  def self.bar',
                                 '    true',
                                 '  end',
                                 'end']
                                 .join("\n"))
      end
    end

    context 'mixed instance and class methods' do
      let(:offending_source) do
        ['class Test',
         '  def foo',
         '    true',
         '  end',
         '  def self.bar',
         '    true',
         '  end',
         'end']
      end

      it 'registers an offense for missing blank line between methods' do
        inspect_source(cop, offending_source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'autocorrects it' do
        corrected = autocorrect_source(cop, offending_source)
        expect(corrected).to eq(['class Test',
                                 '  def foo',
                                 '    true',
                                 '  end',
                                 '',
                                 '  def self.bar',
                                 '    true',
                                 '  end',
                                 'end']
                                 .join("\n"))
      end
    end
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows a line with code' do
    source = ['x = 0',
              'def m',
              'end']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows code and a comment' do
    source = ['  x = 0',
              '  # 123',
              '  def m',
              '  end']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts the first def without leading empty line in a class' do
    source = ['class K',
              '  def m',
              '  end',
              'end']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
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
    expect(cop.offenses).to be_empty
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

  it 'registers an offense for adjacent one-liners by default' do
    source = ['def a; end',
              'def b; end']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects adjacent one-liners by default' do
    corrected = autocorrect_source(cop, ['  def a; end',
                                         '  def b; end'])
    expect(corrected).to eq(['  def a; end',
                             '',
                             '  def b; end'].join("\n"))
  end

  it 'treats lines with whitespaces as blank' do
    source = ['  class J',
              '    def n',
              '    end',
              '    ',
              '    def o',
              '    end',
              '  end']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  context 'when AllowAdjacentOneLineDefs is enabled' do
    let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

    it 'accepts adjacent one-liners' do
      source = ['def a; end',
                'def b; end']
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for adjacent defs if some are multi-line' do
      source = ['def a; end',
                'def b; end',
                'def c', # Not a one-liner, so this is an offense.
                'end',
                # Also an offense since previous was multi-line:
                'def d; end'
               ]
      inspect_source(cop, source)
      expect(cop.offenses.map(&:line)).to eq([3, 5])
    end
  end
end
