# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Proc do
  subject(:cop) { described_class.new }

  it 'registers an offence for a Proc.new call' do
    inspect_source(cop, ['f = Proc.new { |x| puts x }'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts the proc method' do
    inspect_source(cop, ['f = proc { |x| puts x }'])
    expect(cop.offences).to be_empty
  end

  it 'accepts the Proc.new call outside of block' do
    inspect_source(cop, ['p = Proc.new'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects Proc.new to proc' do
    corrected = autocorrect_source(cop, ['Proc.new { test }'])
    expect(corrected).to eq 'proc { test }'
  end
end
