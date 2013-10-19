# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrailingBlankLines do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    Rubocop::Config.new('TrailingWhitespace' => { 'Enabled' => true })
  end

  it 'accepts final newline' do
    inspect_source(cop, ['x = 0', ''])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for multiple trailing blank lines' do
    inspect_source(cop, ['x = 0', '', '', '', ''])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['3 trailing blank lines detected.'])
  end

  it 'auto-corrects unwanted blank lines' do
    new_source = autocorrect_source(cop, ['x = 0', '', '', '', ''])
    expect(new_source).to eq(['x = 0', ''].join("\n"))
  end

  it 'does not auto-correct if it interferes with TrailingWhitespace' do
    original = ['x = 0', '', '  ', '', '']
    new_source = autocorrect_source(cop, original)
    expect(new_source).to eq(original.join("\n"))
  end

  context 'with TrailingWhitespace disabled' do
    let(:config) do
      Rubocop::Config.new('TrailingWhitespace' => { 'Enabled' => false })
    end

    it 'auto-corrects even if some lines have space' do
      new_source = autocorrect_source(cop, ['x = 0', '', '  ', '', ''])
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end
  end
end
