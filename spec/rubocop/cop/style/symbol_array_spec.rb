# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolArray, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for arrays of symbols', ruby: 2 do
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
    end

    it 'does not reg an offense for array with non-syms', ruby: 2 do
      inspect_source(cop, '[:one, :two, "three"]')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense for array starting with %i', ruby: 2 do
      inspect_source(cop, '%i(one two three)')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense for array with one element', ruby: 2 do
      inspect_source(cop, '[:three]')
      expect(cop.offenses).to be_empty
    end

    it 'does not reg an offense if symbol contains whitespace', ruby: 2 do
      inspect_source(cop, '[:one, :two, :"space here"]')
      expect(cop.offenses).to be_empty
    end

    it 'does nothing on Ruby 1.9', ruby: 1.9 do
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is array' do
    let(:cop_config) { { 'EnforcedStyle' => 'brackets' } }

    it 'does not registers an offense for arrays of symbols', ruby: 2 do
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for array starting with %i', ruby: 2 do
      inspect_source(cop, '%i(one two three)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `[]` for an array of symbols.'])
    end
  end
end
