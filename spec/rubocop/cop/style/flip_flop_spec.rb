# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::FlipFlop do
  subject(:cop) { described_class.new }

  it 'registers an offense for inclusive flip flops' do
    inspect_source(cop,
                   ['DATA.each_line do |line|',
                    'print line if (line =~ /begin/)..(line =~ /end/)',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for exclusive flip flops' do
    inspect_source(cop,
                   ['DATA.each_line do |line|',
                    'print line if (line =~ /begin/)...(line =~ /end/)',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end
end
