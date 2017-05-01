# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassVars do
  subject(:cop) { described_class.new }

  it 'registers an offense for class variable declaration' do
    inspect_source(cop, 'class TestClass; @@test = 10; end')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace class var @@test with a class instance var.'])
  end

  it 'does not register an offense for class variable usage' do
    expect_no_offenses('@@test.test(20)')
  end
end
