# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MethodCalledOnDoEndBlock do
  subject(:cop) { described_class.new }
  let(:msg) { Rubocop::Cop::Style::MethodCalledOnDoEndBlock::MSG }

  it 'does not accept a multi-line block chained with calls' do
    inspect_source(cop, ['a do',
                         '  b',
                         'end.c.d'])
    expect(cop.offences.length).to eq(1)
    expect(cop.messages).to eq([msg])
  end

  it 'does not accept a single-line do/end block with calls' do
    inspect_source(cop, ['a do |b| b; end.c'])
    expect(cop.offences.length).to eq(1)
    expect(cop.messages).to eq([msg])
  end

  it 'does accept a multi-line block chained with braces' do
    inspect_source(cop, ['a {',
                         '  b',
                         '}.c.d'])
    expect(cop.offences).to be_empty
  end

  it 'does accept a single line block with braces' do
    inspect_source(cop, ['a { b }.c.d'])
    expect(cop.offences).to be_empty
  end
end
