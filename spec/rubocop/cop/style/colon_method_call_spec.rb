# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ColonMethodCall do
  subject(:cop) { described_class.new }

  it 'registers an offence for instance method call' do
    inspect_source(cop,
                   ['test::method_name'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for instance method call with arg' do
    inspect_source(cop,
                   ['test::method_name(arg)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for class method call' do
    inspect_source(cop,
                   ['Class::method_name'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for class method call with arg' do
    inspect_source(cop,
                   ['Class::method_name(arg, arg2)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for constant access' do
    inspect_source(cop,
                   ['Tip::Top::SOME_CONST'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for nested class' do
    inspect_source(cop,
                   ['Tip::Top.some_method'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for op methods' do
    inspect_source(cop,
                   ['Tip::Top.some_method[3]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence when for constructor methods' do
    inspect_source(cop,
                   ['Tip::Top(some_arg)'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects "::" with "."' do
    new_source = autocorrect_source(cop, 'test::method')
    expect(new_source).to eq('test.method')
  end
end
