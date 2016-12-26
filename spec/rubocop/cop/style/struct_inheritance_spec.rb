# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::StructInheritance do
  subject(:cop) { described_class.new }

  it 'registers an offense when extending instance of Struct' do
    inspect_source(cop,
                   ['class Person < Struct.new(:first_name, :last_name)',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when extending instance of Struct with do ... end' do
    inspect_source(cop,
                   ['class Person < Struct.new(:first_name, :last_name) do end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts plain class' do
    inspect_source(cop,
                   ['class Person',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts extending DelegateClass' do
    inspect_source(cop,
                   ['class Person < DelegateClass(Animal)',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts assignment to Struct.new' do
    inspect_source(cop, 'Person = Struct.new(:first_name, :last_name)')
    expect(cop.offenses).to be_empty
  end
end
