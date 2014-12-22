# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolArray do
  subject(:cop) { described_class.new }

  it 'registers an offense for arrays of symbols', ruby: 2 do
    inspect_source(cop,
                   '[:one, :two, :three]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not reg an offense for array with non-syms', ruby: 2 do
    inspect_source(cop,
                   '[:one, :two, "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not reg an offense for array starting with %i', ruby: 2 do
    inspect_source(cop,
                   '%i(one two three)')
    expect(cop.offenses).to be_empty
  end

  it 'does not reg an offense for array with one element', ruby: 2 do
    inspect_source(cop,
                   '[:three]')
    expect(cop.offenses).to be_empty
  end

  it 'does nothing on Ruby 1.9', ruby: 1.9 do
    inspect_source(cop,
                   '[:one, :two, :three]')
    expect(cop.offenses).to be_empty
  end
end
