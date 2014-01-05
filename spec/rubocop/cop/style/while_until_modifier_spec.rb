# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::WhileUntilModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'LineLength' => { 'Max' => 79 } }
    Rubocop::Config.new(hash)
  end

  it "accepts multiline unless that doesn't fit on one line" do
    check_too_long(cop, 'unless')
  end

  it 'accepts multiline unless whose body is more than one line' do
    check_short_multiline(cop, 'unless')
  end

  it 'registers an offence for multiline while that fits on one line' do
    check_really_short(cop, 'while')
  end

  it "accepts multiline while that doesn't fit on one line" do
    check_too_long(cop, 'while')
  end

  it 'accepts multiline while whose body is more than one line' do
    check_short_multiline(cop, 'while')
  end

  it 'accepts oneline while when condition has local variable assignment' do
    inspect_source(cop, ['lines = %w{first second third}',
                         'while (line = lines.shift)',
                         '  puts line',
                         'end'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for oneline while when assignment is in body' do
    inspect_source(cop, ['while true',
                         '  x = 0',
                         'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for multiline until that fits on one line' do
    check_really_short(cop, 'until')
  end

  it "accepts multiline until that doesn't fit on one line" do
    check_too_long(cop, 'until')
  end

  it 'accepts multiline until whose body is more than one line' do
    check_short_multiline(cop, 'until')
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'while')
    check_empty(cop, 'until')
  end

  it 'accepts modifier while' do
    inspect_source(cop, ['ala while bala'])
    expect(cop.offences).to be_empty
  end

  it 'accepts modifier until' do
    inspect_source(cop, ['ala until bala'])
    expect(cop.offences).to be_empty
  end
end
