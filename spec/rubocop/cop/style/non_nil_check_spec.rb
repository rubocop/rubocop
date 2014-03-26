# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::NonNilCheck do
  subject(:cop) { described_class.new }

  it 'registers an offense for != nil' do
    inspect_source(cop,
                   ['x != nil'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for !x.nil?' do
    inspect_source(cop,
                   ['!x.nil?'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for not x.nil?' do
    inspect_source(cop,
                   ['not x.nil?'])
    expect(cop.offenses.size).to eq(1)
  end
end
