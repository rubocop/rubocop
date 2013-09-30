# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ClassVars do
  subject(:cop) { described_class.new }

  it 'registers an offence for class variable declaration' do
    inspect_source(cop, ['class TestClass; @@test = 10; end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace class var @@test with a class instance var.'])
  end

  it 'does not register an offence for class variable usage' do
    inspect_source(cop, ['@@test.test(20)'])
    expect(cop.offences).to be_empty
  end
end
