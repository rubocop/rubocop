# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CaseEquality do
  subject(:cop) { described_class.new }

  it 'registers an offence for ===' do
    inspect_source(cop, ['Array === var'])
    expect(cop.offences.size).to eq(1)
  end
end
