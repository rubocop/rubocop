# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EmptyLines do
  subject(:cop) { described_class.new }

  it 'registers an offence for consecutive empty lines' do
    inspect_source(cop,
                   ['test = 5', '', '', '', 'top'])
    expect(cop.offences.size).to eq(2)
  end

  it 'auto-corrects consecutive empty lines' do
    corrected = autocorrect_source(cop,
                                   ['test = 5', '', '', '', 'top'])
    expect(corrected).to eq ['test = 5', '', 'top'].join("\n")
  end

  it 'works when there are no tokens' do
    inspect_source(cop,
                   ['#comment'])
    expect(cop.offences).to be_empty
  end

  it 'handles comments' do
    inspect_source(cop,
                   ['test', '', '#comment', 'top'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for empty lines in a string' do
    inspect_source(cop, ['result = "test



                                  string"'])
    expect(cop.offences).to be_empty
  end
end
