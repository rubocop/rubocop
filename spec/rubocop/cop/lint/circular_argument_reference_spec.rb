# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::CircularArgumentReference do
  subject(:cop) { described_class.new }

  describe 'circular argument references in ordinal arguments' do
    before(:each) do
      inspect_source(cop, source)
    end

    context 'when the method contains a circular argument reference' do
      let(:source) do
        [
          'def omg_wow(msg = msg)',
          '  puts msg',
          'end'
        ]
      end

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message)
          .to eq('Circular argument reference - `msg`.')
        expect(cop.highlights).to eq ['msg']
      end
    end

    context 'when the method does not contain a circular argument reference' do
      let(:source) do
        [
          'def omg_wow(msg)',
          '  puts msg',
          'end'
        ]
      end

      it 'does not register an offense' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when the seemingly-circular default value is a method call' do
      let(:source) do
        [
          'def omg_wow(msg = self.msg)',
          '  puts msg',
          'end'
        ]
      end

      it 'does not register an offense' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  describe 'circular argument references in keyword arguments' do
    context 'ruby < 2.0, which has no keyword arguments', :ruby19 do
      let(:source) do
        [
          'def some_method(some_arg: some_method)',
          '  puts some_arg',
          'end'
        ]
      end

      it 'fails with a syntax error before the cop even comes into play' do
        expect { inspect_source(cop, source) }.to raise_error(
          RuntimeError, /Error parsing/
        )
        expect(cop.offenses).to be_empty
      end
    end

    context 'ruby >= 2.0', :ruby20 do
      before(:each) do
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
          expect(cop.offenses).to be_empty
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
          expect(cop.offenses).to be_empty
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

      context 'when the keyword argument is not circular, but calls a method ' \
              'of its own class with a self specification' do
        let(:source) do
          [
            'def puts_value(value: self.class.value, smile: self.smile)',
            '  puts value',
            'end'
          ]
        end

        it 'does not register an offense' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'when the keyword argument is not circular, but calls a method ' \
              'of some other object with the same name' do
        let(:source) do
          [
            'def puts_length(length: mystring.length)',
            '  puts length',
            'end'
          ]
        end

        it 'does not register an offense' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'when there are multiple offensive keyword arguments' do
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
          expect(cop.highlights).to eq %w[some_arg other_arg]
        end
      end
    end
  end
end
