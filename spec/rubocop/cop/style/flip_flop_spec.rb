# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FlipFlop do
  subject(:cop) { described_class.new }

  it 'registers an offence for inclusive flip flops' do
    inspect_source(cop,
                   ['DATA.each_line do |line|',
                    'print line if (line =~ /begin/)..(line =~ /end/)',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for exclusive flip flops' do
    inspect_source(cop,
                   ['DATA.each_line do |line|',
                    'print line if (line =~ /begin/)...(line =~ /end/)',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end
end
