# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ModuleFunction do
  subject(:cop) { described_class.new }

  it 'registers an offence for extend self in module' do
    inspect_source(cop,
                   ['module Test',
                    '  extend self',
                    '  def test; end',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts extend self in class' do
    inspect_source(cop,
                   ['class Test',
                    '  extend self',
                    'end'])
    expect(cop.offences).to be_empty
  end
end
