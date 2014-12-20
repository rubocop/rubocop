# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::Eval do
  subject(:cop) { described_class.new }

  it 'registers an offense for eval as function' do
    inspect_source(cop,
                   'eval(something)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights) .to eq(['eval'])
  end

  it 'registers an offense for eval as command' do
    inspect_source(cop,
                   'eval something')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights) .to eq(['eval'])
  end

  it 'does not register an offense for eval as variable' do
    inspect_source(cop,
                   'eval = something')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for eval as method' do
    inspect_source(cop,
                   'something.eval')
    expect(cop.offenses).to be_empty
  end
end
