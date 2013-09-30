# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Tab do
  subject(:cop) { described_class.new }

  it 'registers an offence for a line indented with tab' do
    inspect_source(cop, ["\tx = 0"])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a line with tab in a string' do
    inspect_source(cop, ["(x = \"\t\")"])
    expect(cop.offences).to be_empty
  end
end
