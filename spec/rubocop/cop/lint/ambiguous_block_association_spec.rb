# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::AmbiguousBlockAssociation do
  subject(:cop) { described_class.new }
  subject(:error_message) do
    'Parenthesize the param to make sure that block will be associated'\
    ' with method call.'
  end

  before do
    inspect_source(cop, source)
  end

  context 'with method and block' do
    context 'without receiver' do
      context 'without parentheses' do
        let(:source) do
          'some_method a { |el| puts el }'
        end

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(error_message)
        end
      end

      context 'with a parentheses' do
        let(:source) do
          'some_method(a) { |el| puts el }'
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with receiver' do
      context 'without parentheses' do
        let(:source) do
          'Foo.some_method a { |el| puts el }'
        end

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(error_message)
        end
      end

      context 'with a parentheses' do
        let(:source) do
          'Foo.some_method(a) { |el| puts el }'
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end
  end
end
