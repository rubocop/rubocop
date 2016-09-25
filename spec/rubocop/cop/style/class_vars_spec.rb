# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ClassVars do
  subject(:cop) { described_class.new }

  it 'registers an offense for class variable declaration' do
    inspect_source(cop, 'class TestClass; @@test = 10; end')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace class var @@test with a class instance var.'])
  end

  it 'does not register an offense for class variable usage' do
    inspect_source(cop, '@@test.test(20)')
    expect(cop.offenses).to be_empty
  end
end
