# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::AmbiguousOperator do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'with a splat operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        let(:source) do
          [
            'array = [1, 2, 3]',
            'puts *array'
          ]
        end

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Ambiguous splat operator. ' \
            "Parenthesize the method arguments if it's surely a splat " \
            'operator, ' \
            'or add a whitespace to the right of the `*` if it should be a ' \
            'multiplication.'
          )
          expect(cop.highlights).to eq(['*'])
        end
      end

      context 'with a whitespace on the right of the operator' do
        let(:source) do
          [
            'array = [1, 2, 3]',
            'puts * array'
          ]
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with parentheses' do
      let(:source) do
        [
          'array = [1, 2, 3]',
          'puts(*array)'
        ]
      end

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'with a block ampersand in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        let(:source) do
          [
            'process = proc { do_something }',
            '2.times &process'
          ]
        end

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Ambiguous block operator. ' \
            "Parenthesize the method arguments if it's surely a block " \
            'operator, ' \
            'or add a whitespace to the right of the `&` if it should be a ' \
            'binary AND.'
          )
          expect(cop.highlights).to eq(['&'])
        end
      end

      context 'with a whitespace on the right of the operator' do
        let(:source) do
          [
            'process = proc { do_something }',
            '2.times & process'
          ]
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with parentheses' do
      let(:source) do
        [
          'process = proc { do_something }',
          '2.times(&process)'
        ]
      end

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end
  end
end
