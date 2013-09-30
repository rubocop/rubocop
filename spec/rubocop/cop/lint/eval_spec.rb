# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Eval do
  subject(:cop) { described_class.new }

  it 'registers an offence for eval as function' do
    inspect_source(cop,
                   ['eval(something)'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['The use of eval is a serious security risk.'])
  end

  it 'registers an offence for eval as command' do
    inspect_source(cop,
                   ['eval something'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['The use of eval is a serious security risk.'])
  end

  it 'does not register an offence for eval as variable' do
    inspect_source(cop,
                   ['eval = something'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for eval as method' do
    inspect_source(cop,
                   ['something.eval'])
    expect(cop.offences).to be_empty
  end
end
