# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::StabbyLambdaParentheses, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common' do
    it 'does not check the old lambda syntax' do
      inspect_source(cop, 'lambda(&:nil?)')
      expect(cop.offenses).to be_empty
    end

    it 'does not check a stabby lambda without arguments' do
      inspect_source(cop, '-> { true }')
      expect(cop.offenses).to be_empty
    end

    it 'does not check a method call named lambda' do
      inspect_source(cop, 'o.lambda')
      expect(cop.offenses).to be_empty
    end
  end

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda without parentheses' do
      inspect_source(cop, '->a,b,c { a + b + c }')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Wrap stabby lambda arguments with parentheses.'])
    end

    it 'does not register an offense for a stabby lambda with parentheses' do
      inspect_source(cop, '->(a,b,c) { a + b + c }')
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects when a stabby lambda has no parentheses' do
      corrected = autocorrect_source(cop, ['->a,b,c { a + b + c }'])
      expect(corrected).to eq '->(a,b,c) { a + b + c }'
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda with parentheses' do
      inspect_source(cop, '->(a,b,c) { a + b + c }')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Do not wrap stabby lambda arguments with parentheses.'])
    end

    it 'autocorrects when a stabby lambda does not parentheses' do
      corrected = autocorrect_source(cop, ['->(a,b,c) { a + b + c }'])
      expect(corrected).to eq '->a,b,c { a + b + c }'
    end
  end
end
