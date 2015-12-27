# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Rails::SafeNavigationOperator do
  subject(:cop) { described_class.new }

  context 'with `try!`' do
    context 'and with a receiver' do
      it 'registers an offense for an invocation with args' do
        inspect_source(cop, 'obj.try! :id')
        expect(cop.offenses.size).to eq(1)
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, 'obj.try!')
        expect(cop.offenses).to be_empty
      end
    end

    context 'and without a receiver' do
      it 'registers an offense for an invocation with args' do
        inspect_source(cop, 'try! :id')
        expect(cop.offenses.size).to eq(1)
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, 'try!')
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'with `&.`' do
    context 'and with a receiver' do
      it 'does not register an offense for an invocation with args' do
        inspect_source(cop, 'obj&.id')
        expect(cop.offenses).to be_empty
      end
    end
  end
end
