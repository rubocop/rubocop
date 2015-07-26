# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::CircularArgumentReference do
  subject(:cop) { described_class.new }
  context 'ruby < 2.0, which has no keyword arguments', ruby_less_than: 2.0 do
    let(:source) do
      [
        'def some_method(some_arg: some_method)',
        '  puts some_arg',
        'end'
      ]
    end

    it 'fails with a syntax error before the cop even comes into play' do
      expect { inspect_source(cop, source) }.to raise_error(
        RuntimeError, /Error parsing/)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'ruby >= 2.0', ruby_greater_than_or_equal: 2.0 do
    before do
      inspect_source(cop, source)
    end

    context 'when the keyword argument is not circular' do
      let(:source) do
        [
          'def some_method(some_arg: nil)',
          '  puts some_arg',
          'end'
        ]
      end

      it 'does not register an offense' do
        expect(cop.offenses.size).to eq(0)
      end
    end

    context 'when the keyword argument is not circular, and calls a method' do
      let(:source) do
        [
          'def some_method(some_arg: some_method)',
          '  puts some_arg',
          'end'
        ]
      end
      it 'does not register an offense' do
        expect(cop.offenses.size).to eq(0)
      end
    end

    context 'when there is one circular argument reference' do
      let(:source) do
        [
          'def some_method(some_arg: some_arg)',
          '  puts some_arg',
          'end'
        ]
      end
      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Circular argument reference - `some_arg`.')
        expect(cop.highlights).to eq ['some_arg']
      end
    end

    context 'when there are multiple offense keyword arguments' do
      let(:source) do
        [
          'def some_method(some_arg: some_arg, other_arg: other_arg)',
          '  puts [some_arg, other_arg]',
          'end'
        ]
      end

      it 'registers two offenses' do
        expect(cop.offenses.size).to eq(2)
        expect(cop.offenses.first.message)
          .to eq('Circular argument reference - `some_arg`.')
        expect(cop.offenses.last.message)
          .to eq('Circular argument reference - `other_arg`.')
        expect(cop.highlights).to eq %w(some_arg other_arg)
      end
    end
  end
end
