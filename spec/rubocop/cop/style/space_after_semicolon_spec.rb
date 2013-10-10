# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offence for semicolon without space after it' do
    inspect_source(cop, ['x = 1;y = 2'])
    expect(cop.messages).to eq(
      ['Space missing after semicolon.'])
  end

  it 'does not crash if semicolon is the last character of the file' do
    inspect_source(cop, ['x = 1;'])
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'x = 1;y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end
end
