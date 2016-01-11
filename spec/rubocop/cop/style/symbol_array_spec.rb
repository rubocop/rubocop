# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolArray, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for arrays of symbols' do
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
    end

    it 'autocorrects arrays of symbols' do
      new_source = autocorrect_source(cop, '[:one, :two, :three]')
      expect(new_source).to eq('%i(one two three)')
    end

    it 'uses %I when appropriate' do
      new_source = autocorrect_source(cop, '[:"\\t", :"\\n", :three]')
      expect(new_source).to eq('%I(\\t \\n three)')
    end

    it "doesn't break when a symbol contains )" do
      new_source = autocorrect_source(cop, '[:one, :")", :three]')
      expect(new_source).to eq('%i(one \\) three)')
    end

    it 'does not reg an offense for array with non-syms' do
      inspect_source(cop, '[:one, :two, "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense for array starting with %i' do
      inspect_source(cop, '%i(one two three)')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense for array with one element' do
      inspect_source(cop, '[:three]')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense if symbol contains whitespace' do
      inspect_source(cop, '[:one, :two, :"space here"]')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is array' do
    let(:cop_config) { { 'EnforcedStyle' => 'brackets' } }

    it 'does not registers an offense for arrays of symbols' do
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for array starting with %i' do
      inspect_source(cop, '%i(one two three)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `[]` for an array of symbols.'])
    end

    it 'autocorrects an array starting with %i' do
      new_source = autocorrect_source(cop, '%i(one two three)')
      expect(new_source).to eq('[:one, :two, :three]')
    end
  end
end
