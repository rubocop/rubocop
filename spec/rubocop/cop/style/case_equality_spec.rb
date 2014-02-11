# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CaseEquality do
  subject(:cop) { described_class.new }

  it 'registers an offense for ===' do
    inspect_source(cop, ['Array === var'])
    expect(cop.offenses.size).to eq(1)
  end
end
