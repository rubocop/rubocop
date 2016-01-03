# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::Delegate do
  subject(:cop) { described_class.new }

  it 'finds trivial delegate' do
    inspect_source(cop,
                   ['def foo',
                    '  bar.foo',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
            .map(&:line).sort).to eq([1])
    expect(cop.messages)
      .to eq(['Use `delegate` to define delegations.'])
    expect(cop.highlights).to eq(['def'])
  end

  it 'finds trivial delegate with arguments' do
    inspect_source(cop,
                   ['def foo(baz)',
                    '  bar.foo(baz)',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
            .map(&:line).sort).to eq([1])
    expect(cop.messages)
      .to eq(['Use `delegate` to define delegations.'])
    expect(cop.highlights).to eq(['def'])
  end

  it 'finds trivial delegate with prefix' do
    inspect_source(cop,
                   ['def bar_foo',
                    '  bar.foo',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses
            .map(&:line).sort).to eq([1])
    expect(cop.messages)
      .to eq(['Use `delegate` to define delegations.'])
    expect(cop.highlights).to eq(['def'])
  end

  it 'ignores class methods' do
    inspect_source(cop,
                   ['def self.fox',
                    '  new.fox',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores non trivial delegate' do
    inspect_source(cop,
                   ['def fox',
                    '  bar.foo.fox',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores trivial delegate with mismatched arguments' do
    inspect_source(cop,
                   ['def fox(baz)',
                    '  bar.fox(foo)',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores trivial delegate with mismatched arguments' do
    inspect_source(cop,
                   ['def fox(foo = nil)',
                    '  bar.fox(foo || 5)',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores trivial delegate with mismatched arguments' do
    inspect_source(cop,
                   ['def fox(a, baz)',
                    '  bar.fox(a)',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores trivial delegate with other prefix' do
    inspect_source(cop,
                   ['def fox_foo',
                    '  bar.foo',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores methods with arguments' do
    inspect_source(cop,
                   ['def fox(bar)',
                    '  bar.fox',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores private delegations' do
    inspect_source(cop,
                   ['  private def fox', # leading spaces are on purpose
                    '    bar.fox',
                    '  end',
                    '  ',
                    '    private',
                    '  ',
                    '  def fox',
                    '    bar.fox',
                    '  end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores protected delegations' do
    inspect_source(cop,
                   ['  protected def fox', # leading spaces are on purpose
                    '    bar.fox',
                    '  end',
                    '  ',
                    '  protected',
                    '  ',
                    '  def fox',
                    '    bar.fox',
                    '  end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores delegation with assignment' do
    inspect_source(cop,
                   ['def new',
                    '  @bar = Foo.new',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores delegation to constant' do
    inspect_source(cop,
                   ['FOO = []',
                    'def size',
                    '  FOO.size',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  describe '#autocorrect' do
    context 'trivial delegation' do
      let(:source) do
        ['def bar',
         '  foo.bar',
         'end']
      end

      let(:corrected_source) { 'delegate :bar, to: :foo' }

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end

    context 'trivial delegation with prefix' do
      let(:source) do
        ['def foo_bar',
         '  foo.bar',
         'end']
      end

      let(:corrected_source) { 'delegate :bar, to: :foo, prefix: true' }

      it 'autocorrects' do
        expect(autocorrect_source(cop, source)).to eq(corrected_source)
      end
    end
  end
end
