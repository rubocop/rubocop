# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Rails::SafeNavigationOperator, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'offensive method' do |method|
    context "with method #{method}" do
      context 'and with a receiver' do
        it 'registers an offense for an invocation with args' do
          inspect_source(cop, "obj.#{method}! :id")
          expect(cop.offenses.size).to eq(1)
        end

        it 'does not register an offense for an invocation without args' do
          inspect_source(cop, "obj.#{method}")
          expect(cop.offenses).to be_empty
        end
      end

      context 'and without a receiver' do
        it 'registers an offense for an invocation with args' do
          inspect_source(cop, "#{method} :id")
          expect(cop.offenses.size).to eq(1)
        end

        it 'does not register an offense for an invocation without args' do
          inspect_source(cop, method)
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  shared_examples 'valid safe navigation operator' do
    context 'with `&.`' do
      context 'and with a receiver' do
        it 'does not register an offense for an invocation with args' do
          inspect_source(cop, 'obj&.id')
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'when `CaptureTry` is `false`' do
    let(:cop_config) { { 'CaptureTry' => false } }

    it_behaves_like 'offensive method', 'try!'

    include_examples 'valid safe navigation operator'
  end

  context 'when `CaptureTry` is `true`' do
    let(:cop_config) { { 'CaptureTry' => true } }

    it_behaves_like 'offensive method', 'try'
    it_behaves_like 'offensive method', 'try!'

    include_examples 'valid safe navigation operator'
  end
end
