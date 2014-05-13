# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Rspec, :config do
  subject(:cop) { described_class.new }

  it 'finds description with `should` at the beginning' do
    inspect_source(cop, ["it 'should do something' do", 'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages)
      .to eq(['Do not use should when describing your tests.'])
    expect(cop.highlights).to eq(['it'])
  end

  it 'skips descriptions without `should` at the beginning' do
    inspect_source(cop, ["it 'finds no should ' \\",
                         "   'here' do",
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
