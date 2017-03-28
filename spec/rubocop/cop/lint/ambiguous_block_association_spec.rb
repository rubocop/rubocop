# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::AmbiguousBlockAssociation do
  subject(:cop) { described_class.new }
  subject(:error_message) { described_class::MSG }

  before { inspect_source(cop, source) }

  shared_examples 'accepts' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  it_behaves_like 'accepts', 'foo ->(a) { bar a }'
  it_behaves_like 'accepts', 'some_method(a) { |el| puts el }'
  it_behaves_like 'accepts', 'some_method(a) do;puts a;end'
  it_behaves_like 'accepts', 'some_method a do;puts "dev";end'
  it_behaves_like 'accepts', 'some_method a do |e|;puts e;end'
  it_behaves_like 'accepts', 'Foo.bar(a) { |el| puts el }'
  it_behaves_like 'accepts', 'env ENV.fetch("ENV") { "dev" }'
  it_behaves_like 'accepts', 'env(ENV.fetch("ENV") { "dev" })'
  it_behaves_like 'accepts', '{ f: "b"}.fetch(:a) do |e|;puts e;end'
  it_behaves_like 'accepts', 'Hash[some_method(a) { |el| el }]'
  it_behaves_like 'accepts', 'foo = lambda do |diagnostic|;end'
  it_behaves_like 'accepts', 'Proc.new { puts "proc" }'
  it_behaves_like('accepts', 'expect { order.save }.to(change { orders.size })')
  it_behaves_like(
    'accepts',
    'allow(cop).to receive(:on_int) { raise RuntimeError }'
  )
  it_behaves_like(
    'accepts',
    'allow(cop).to(receive(:on_int) { raise RuntimeError })'
  )

  context 'without parentheses' do
    context 'without receiver' do
      let(:source) { 'some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a', 'some_method'))
        )
      end
    end

    context 'with receiver' do
      let(:source) { 'Foo.some_method a { |el| puts el }' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a', 'some_method'))
        )
      end
    end

    context 'rspec expect {}.to change {}' do
      let(:source) do
        'expect { order.expire }.to change { order.events }'
      end

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'change', 'to'))
        )
      end
    end

    context 'as a hash key' do
      let(:source) { 'Hash[some_method a { |el| el }]' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to(
          eq(format(error_message, 'a', 'some_method'))
        )
      end
    end

    context 'with assignment' do
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
