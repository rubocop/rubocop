# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::BeginBlock do
  subject(:cop) { described_class.new }

  it 'reports an offence for a BEGIN block' do
    src = ['BEGIN { test }']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end
end
