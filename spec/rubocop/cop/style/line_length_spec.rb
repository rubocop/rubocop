# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::LineLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 79 } }

  it "registers an offence for a line that's 80 characters wide" do
    inspect_source(cop, ['#' * 80])
    expect(cop.offences.size).to eq(1)
    expect(cop.offences.first.message).to eq('Line is too long. [80/79]')
    expect(cop.config_to_allow_offences).to eq('Max' => 80)
  end

  it "accepts a line that's 79 characters wide" do
    inspect_source(cop, ['#' * 79])
    expect(cop.offences).to be_empty
  end
end
