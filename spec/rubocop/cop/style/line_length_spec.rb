# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::LineLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 80 } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source(cop, ['#' * 81])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq('Max' => 81)
  end

  it "accepts a line that's 80 characters wide" do
    inspect_source(cop, ['#' * 80])
    expect(cop.offenses).to be_empty
  end
end
