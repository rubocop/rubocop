# encoding: utf-8

require 'spec_helper'

shared_examples_for 'chained multi-line blocks' do
  context 'with multi-line block chaining' do
    it 'registers an offence for a simple case' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c do',
                           '  d',
                           'end'])
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['end.c'])
      expect(cop.messages).to eq(['Avoid multi-line chains of blocks.'])
    end

    it 'registers an offence for a slightly more complicated case' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c1.c2 do',
                           '  d',
                           'end'])
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['end.c1.c2'])
      expect(cop.messages).to eq(['Avoid multi-line chains of blocks.'])
    end

    it 'accepts a chain where the first block is single-line' do
      inspect_source(cop,
                     ['Thread.list.select { |t| t.alive? }.map { |t| ',
                      '  t.object_id',
                      '}'])
      expect(cop.offences).to be_empty
    end

    it 'registers two offences for a chain of three blocks' do
      inspect_source(cop, ['a do',
                           '  b',
                           'end.c do',
                           '  d',
                           'end.e do',
                           '  f',
                           'end'])
      expect(cop.offences).to have(2).items
      expect(cop.highlights).to eq(['end.c', 'end.e'])
      expect(cop.messages).to eq(['Avoid multi-line chains of blocks.'] * 2)
    end

    it 'registers an offence for a chain where the second block is ' +
      'single-line' do
      inspect_source(cop, ['Thread.list.find_all { |t|',
                           '  t.alive?',
                           '}.map { |thread| thread.object_id }'])
      expect(cop.offences).to have(1).item
      expect(cop.highlights).to eq(['}.map'])
      expect(cop.messages).to eq(['Avoid multi-line chains of blocks.'])
    end
  end
end

shared_examples_for 'other chaining with blocks' do
  it 'accepts a chain of blocks spanning one line' do
    inspect_source(cop, ['a { b }.c { d }',
                         'w do x end.y do z end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a chain of calls followed by a multi-line block' do
    inspect_source(cop, ['a1.a2.a3 do',
                         '  b',
                         'end'])
    expect(cop.offences).to be_empty
  end
end

module Rubocop
  module Cop
    module Style
      describe MultilineBlockChain, :config do
        subject(:cop) { described_class.new(config) }

        context 'when configured to allow method calls on block' do
          let(:cop_config) { { 'AllowMethodCalledOnBlock' => true } }

          include_examples 'chained multi-line blocks'
          include_examples 'other chaining with blocks'

          it 'accepts a multi-line block chained with calls on one line' do
            inspect_source(cop, ['a do',
                                 '  b',
                                 'end.c.d'])
            expect(cop.offences).to be_empty
          end
        end

        context 'when configured to not allow method calls on block' do
          let(:cop_config) { { 'AllowMethodCalledOnBlock' => false } }

          include_examples 'chained multi-line blocks'
          include_examples 'other chaining with blocks'

          it 'registers an offence for a multi-line block chained with ' +
            'calls on one line' do
            inspect_source(cop, ['a do',
                                 '  b',
                                 'end.c.d'])
            expect(cop.offences).to have(1).item
            expect(cop.messages)
              .to eq(['Avoid chaining a method call on a multi-line block.'])
            expect(cop.highlights).to eq(['end.c'])
          end
        end
      end
    end
  end
end
