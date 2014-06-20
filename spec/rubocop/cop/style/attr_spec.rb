# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Attr do
  subject(:cop) { described_class.new }

  it 'registers an offense attr' do
    inspect_source(cop, ['class SomeClass',
                         '  attr :name',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts attr when it does not take arguments' do
    inspect_source(cop, 'func(attr)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts attr when it has a receiver' do
    inspect_source(cop, 'x.attr arg')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects attr to attr_reader' do
    new_source = autocorrect_source(cop, 'attr :name')
    expect(new_source).to eq('attr_reader :name')
  end
end
