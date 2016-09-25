# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ConstantName do
  subject(:cop) { described_class.new }

  it 'registers an offense for camel case in const name' do
    inspect_source(cop,
                   'TopCase = 5')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers offenses for camel case in multiple const assignment' do
    inspect_source(cop,
                   'TopCase, Test2, TEST_3 = 5, 6, 7')
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers an offense for snake case in const name' do
    inspect_source(cop,
                   'TOP_test = 5')
    expect(cop.offenses.size).to eq(1)
  end

  it 'allows screaming snake case in const name' do
    inspect_source(cop,
                   'TOP_TEST = 5')
    expect(cop.offenses).to be_empty
  end

  it 'allows screaming snake case in multiple const assignment' do
    inspect_source(cop,
                   'TOP_TEST, TEST_2 = 5, 6')
    expect(cop.offenses).to be_empty
  end

  it 'does not check names if rhs is a method call' do
    inspect_source(cop,
                   'AnythingGoes = test')
    expect(cop.offenses).to be_empty
  end

  it 'does not check names if rhs is a method call with block' do
    inspect_source(cop,
                   ['AnythingGoes = test do',
                    '  do_something',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not check if rhs is another constant' do
    inspect_source(cop,
                   'Parser::CurrentRuby = Parser::Ruby20')
    expect(cop.offenses).to be_empty
  end

  it 'checks qualified const names' do
    inspect_source(cop,
                   ['::AnythingGoes = 30',
                    'a::Bar_foo = 10'])
    expect(cop.offenses.size).to eq(2)
  end
end
