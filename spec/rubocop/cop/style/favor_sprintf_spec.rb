# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FavorSprintf do
  subject(:cop) { described_class.new }

  it 'registers an offence for a string followed by something' do
    inspect_source(cop,
                   ['puts "%d" % 10'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Favor sprintf over String#%.'])
  end

  it 'registers an offence for something followed by an array' do
    inspect_source(cop,
                   ['puts x % [10, 11]'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Favor sprintf over String#%.'])
  end

  it 'does not register an offence for numbers' do
    inspect_source(cop,
                   ['puts 10 % 4'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for ambiguous cases' do
    inspect_source(cop,
                   ['puts x % 4'])
    expect(cop.offences).to be_empty

    inspect_source(cop,
                   ['puts x % Y'])
    expect(cop.offences).to be_empty
  end

  it 'works if the first operand contains embedded expressions' do
    inspect_source(cop,
                   ['puts "#{x * 5} %d #{@test}" % 10'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Favor sprintf over String#%.'])
  end
end
