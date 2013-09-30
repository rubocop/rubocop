# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrailingBlankLines do
  subject(:cop) { described_class.new }

  it 'accepts final newline' do
    inspect_source(cop, ['x = 0', ''])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for multiple trailing blank lines' do
    inspect_source(cop, ['x = 0', '', '', '', ''])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['3 trailing blank lines detected.'])
  end
end
