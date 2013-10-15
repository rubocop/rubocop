# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SymbolArray do
  subject(:cop) { described_class.new }

  it 'registers an offence for arrays of symbols', ruby: 2.0 do
    inspect_source(cop,
                   ['[:one, :two, :three]'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not reg an offence for array with non-syms', ruby: 2.0 do
    inspect_source(cop,
                   ['[:one, :two, "three"]'])
    expect(cop.offences).to be_empty
  end

  it 'does not reg an offence for array starting with %i', ruby: 2.0 do
    inspect_source(cop,
                   ['%i(one two three)'])
    expect(cop.offences).to be_empty
  end

  it 'does not reg an offence for array with one element', ruby: 2.0 do
    inspect_source(cop,
                   ['[:three]'])
    expect(cop.offences).to be_empty
  end

  it 'does nothing on Ruby 1.9', ruby: 1.9 do
    inspect_source(cop,
                   ['[:one, :two, :three]'])
    expect(cop.offences).to be_empty
  end
end
