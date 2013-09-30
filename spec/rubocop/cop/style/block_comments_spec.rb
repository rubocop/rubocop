# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::BlockComments do
  subject(:cop) { described_class.new }

  it 'registers an offence for block comments' do
    inspect_source(cop,
                   ['=begin',
                    'comment',
                    '=end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts regular comments' do
    inspect_source(cop,
                   ['# comment'])
    expect(cop.offences).to be_empty
  end
end
