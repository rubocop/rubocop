# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::AmbiguousBlockAssociation do
  subject(:cop) { described_class.new }
  subject(:error_message) do
    'Parenthesize the param `%s` to make sure that block will be associated'\
      ' with `%s` method call.'
  end

  before do
    inspect_source(cop, source)
  end

  context 'method without params and block' do
    context 'without receiver' do
      context 'without parentheses' do
        let(:source) { 'some_method a { |el| puts el }' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to(
            eq(format(error_message, 'a', 'some_method'))
          )
        end
      end

      context 'with parentheses' do
        let(:source) { 'some_method(a) { |el| puts el }' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with receiver' do
      context 'without parentheses' do
        let(:source) { 'Foo.some_method a { |el| puts el }' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to(
            eq(format(error_message, 'a', 'some_method'))
          )
        end
      end

      context 'with a parentheses' do
        let(:source) { 'Foo.some_method(a) { |el| puts el }' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'method with arguments and block' do
    context 'without parantheses' do
      context 'with receiver' do
        let(:source) { 'environment ENV.fetch("RAILS_ENV") { "development" }' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'witout receiver' do
        let(:source) { 'allow(cop).to receive(:on_int) { raise RuntimeError }' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with parantheses' do
      context 'with receiver' do
        let(:source) { 'environment(ENV.fetch("RAILS_ENV") { "development" })' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'witout receiver' do
        let(:source) { 'allow(cop).to(receive(:on_i) { raise RuntimeError })' }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'multiline blocks' do
    context 'without parentheses' do
      context 'without block param' do
        let(:source) { ['some_method a do', 'puts "here"', 'end'] }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'with block param' do
        let(:source) { ['some_method a do |el|', 'puts el', 'end'] }

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'rspec expect {}.to change {}' do
      context 'without parentheses' do
        let(:source) do
          'expect { order.expire }.not_to change { order.unpublished_events }'
        end

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to(
            eq(format(error_message, 'change', 'not_to'))
          )
        end
      end

      context 'with parentheses' do
        let(:source) do
          'expect { order.expire }.not_to(change { order.unpublished_events })'
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with parentheses' do
      context 'without block param' do
        let(:source) do
          ['some_method(a) do', 'puts "here"', 'end']
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end

      context 'with block param' do
        let(:source) do
          ['{ foo: "bar"}.fetch(:a) do |el|', 'puts el', 'end']
        end

        it 'accepts' do
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'inside Hash' do
    context 'method with a block' do
      let(:source) do
        'Hash[some_method(a) { |el| el }]'
      end

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'with assignment' do
    context 'with lambda' do
      let(:source) do
        ['foo = lambda do |diagnostic|', 'end']
      end

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'variable assignment' do
      let(:source) { 'foo = some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a', 'some_method'))
        )
      end
    end
  end
end
