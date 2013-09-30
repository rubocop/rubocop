# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EndBlock do
  subject(:cop) { described_class.new }

  it 'reports an offence for an END block' do
    src = ['END { test }']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end
end
