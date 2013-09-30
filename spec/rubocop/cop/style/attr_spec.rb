# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Attr do
  subject(:cop) { described_class.new }

  it 'registers an offence attr' do
    inspect_source(cop, ['class SomeClass',
                         '  attr :name',
                         'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'auto-corrects attr to attr_reader' do
    new_source = autocorrect_source(cop, 'attr')
    expect(new_source).to eq('attr_reader')
  end
end
